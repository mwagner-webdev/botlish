// host_async.cpp -- the census's asynchronous probe (REACT-NATIVE-TARGET-
// CENSUS.md, "Async and coroutine semantics"): a Promise-returning Pure C++
// TurboModule (the Codegen spec NativeBotlishAsyncCxxSpec of
// host/NativeBotlishAsync.ts) whose Botlish calls
// run on one dedicated worker thread with a large stack, never on the JS
// thread. React Native's AsyncPromise settles each promise; it schedules the
// settlement back onto the JS thread through the module's CallInvoker, which
// here is a thread-safe queue the JS thread drains, as React Native's JS
// message queue is. Hand-written: the generated adapter is synchronous.
//
// Built and run by tools/host-spike.tcl (`host_async host/async.js`); the
// script sets globalThis.done when its promises have settled.
#include <BotlishProbeSpecJSI.h>
#include <ReactCommon/CallInvoker.h>
#include <ReactCommon/TurboModuleBinding.h>
#include <hermes/hermes.h>
#include <pthread.h>

#include "rnprobe.h"

#include <chrono>
#include <condition_variable>
#include <deque>
#include <fstream>
#include <functional>
#include <iostream>
#include <mutex>
#include <sstream>

using namespace facebook;
using namespace facebook::react;

namespace {

// The JS thread's task queue, fed from any thread.
class QueueInvoker : public CallInvoker {
 public:
  std::mutex mutex;
  std::condition_variable ready;
  std::deque<CallFunc> tasks;
  void invokeAsync(CallFunc &&func) noexcept override {
    std::lock_guard<std::mutex> lock(mutex);
    tasks.push_back(std::move(func));
    ready.notify_one();
  }
  void invokeSync(CallFunc &&) override { std::abort(); }
};

// One thread that owns a Botlish library instance -- created and destroyed on
// it, as the library's thread rule requires (NATIVE-LIBRARY-MILESTONE-1.md) --
// and runs jobs in order with it, on a stack the size of a Botlish
// executable's worker's.
class BotlishWorker {
 public:
  explicit BotlishWorker(size_t stackBytes) {
    pthread_attr_t attr;
    pthread_attr_init(&attr);
    pthread_attr_setstacksize(&attr, stackBytes);
    pthread_create(&thread_, &attr, &BotlishWorker::run, this);
    pthread_attr_destroy(&attr);
  }
  ~BotlishWorker() {
    {
      std::lock_guard<std::mutex> lock(mutex_);
      stopping_ = true;
    }
    ready_.notify_one();
    pthread_join(thread_, nullptr);
  }
  void post(std::function<void(rnprobe_instance *)> job) {
    std::lock_guard<std::mutex> lock(mutex_);
    jobs_.push_back(std::move(job));
    ready_.notify_one();
  }

 private:
  static void *run(void *self) {
    static_cast<BotlishWorker *>(self)->loop();
    return nullptr;
  }
  void loop() {
    rnprobe_instance *instance = nullptr;
    rnprobe_error *error = nullptr;
    if (rnprobe_create(&instance, &error) != rnprobe_OK) {
      rnprobe_error_release(error);
      instance = nullptr;  // every job's call is then an INVOCATION_ERROR
    }
    for (;;) {
      std::function<void(rnprobe_instance *)> job;
      {
        std::unique_lock<std::mutex> lock(mutex_);
        ready_.wait(lock, [this] { return stopping_ || !jobs_.empty(); });
        if (jobs_.empty()) {
          break;
        }
        job = std::move(jobs_.front());
        jobs_.pop_front();
      }
      job(instance);
    }
    if (instance != nullptr) {
      rnprobe_destroy(instance);
    }
  }
  pthread_t thread_;
  std::mutex mutex_;
  std::condition_variable ready_;
  std::deque<std::function<void(rnprobe_instance *)>> jobs_;
  bool stopping_ = false;
};

// The error's identity and message, as one line; the error is released.
std::string describe(rnprobe_error *error) {
  rnprobe_text identity = {nullptr, 0}, message = {nullptr, 0};
  rnprobe_error_identity(error, &identity);
  rnprobe_error_message(error, &message);
  std::string text = std::string(reinterpret_cast<const char *>(identity.data), identity.len) + ": " +
      std::string(reinterpret_cast<const char *>(message.data), message.len);
  rnprobe_error_release(error);
  return text;
}

class BotlishAsyncModule : public NativeBotlishAsyncCxxSpec<BotlishAsyncModule> {
 public:
  explicit BotlishAsyncModule(std::shared_ptr<CallInvoker> jsInvoker)
      : NativeBotlishAsyncCxxSpec(std::move(jsInvoker)), worker_(std::make_shared<BotlishWorker>(256u << 20)) {}

  AsyncPromise<double> depth(jsi::Runtime &rt, double n) {
    AsyncPromise<double> promise(rt, jsInvoker_);
    int64_t k = static_cast<int64_t>(n);
    worker_->post([promise, k](rnprobe_instance *instance) mutable {
      int64_t out = 0;
      rnprobe_error *error = nullptr;
      if (rnprobe_depth(instance, k, &out, &error) == rnprobe_OK) {
        promise.resolve(static_cast<double>(out));
      } else {
        promise.reject(Error(describe(error)));
      }
    });
    return promise;
  }

  AsyncPromise<std::string> reverse(jsi::Runtime &rt, std::string s) {
    AsyncPromise<std::string> promise(rt, jsInvoker_);
    worker_->post([promise, s = std::move(s)](rnprobe_instance *instance) mutable {
      rnprobe_bytes out = {nullptr, 0};
      rnprobe_error *error = nullptr;
      if (rnprobe_reverse(instance, reinterpret_cast<const uint8_t *>(s.data()), s.size(), &out, &error) == rnprobe_OK) {
        // The result is the caller's buffer: copy it, give it back.
        std::string text(reinterpret_cast<const char *>(out.data), out.len);
        rnprobe_bytes_release(&out);
        promise.resolve(text);
      } else {
        promise.reject(Error(describe(error)));
      }
    });
    return promise;
  }

 private:
  std::shared_ptr<BotlishWorker> worker_;
};

} // namespace

int main(int argc, char **argv) {
  if (argc != 2) {
    std::cerr << "usage: host_async SCRIPT.js\n";
    return 2;
  }
  std::ifstream file(argv[1]);
  std::stringstream source;
  source << file.rdbuf();
  auto invoker = std::make_shared<QueueInvoker>();
  {
    // React Native runs Hermes with its microtask queue (promise jobs run
    // after each task, drained below).
    auto runtime = facebook::hermes::makeHermesRuntime(
        ::hermes::vm::RuntimeConfig::Builder().withMicrotaskQueue(true).build());
    jsi::Runtime &rt = *runtime;
    rt.global().setProperty(rt, "print", jsi::Function::createFromHostFunction(rt, jsi::PropNameID::forAscii(rt, "print"), 1,
        [](jsi::Runtime &rt, const jsi::Value &, const jsi::Value *args, size_t count) {
          for (size_t i = 0; i < count; i++) {
            std::cout << (i ? " " : "") << args[i].toString(rt).utf8(rt);
          }
          std::cout << std::endl;
          return jsi::Value::undefined();
        }));
    TurboModuleBinding::install(rt, [invoker](jsi::Runtime &, const std::string &name) -> std::shared_ptr<TurboModule> {
      if (name == BotlishAsyncModule::kModuleName) {
        return std::make_shared<BotlishAsyncModule>(invoker);
      }
      return nullptr;
    });
    try {
      rt.evaluateJavaScript(std::make_shared<jsi::StringBuffer>(source.str()), argv[1]);
      auto deadline = std::chrono::steady_clock::now() + std::chrono::seconds(60);
      for (;;) {
        auto done = rt.global().getProperty(rt, "done");
        if (done.isBool() && done.getBool()) {
          break;
        }
        std::unique_lock<std::mutex> lock(invoker->mutex);
        if (!invoker->ready.wait_until(lock, deadline, [&] { return !invoker->tasks.empty(); })) {
          std::cerr << "timed out waiting for promises" << std::endl;
          return 1;
        }
        auto task = std::move(invoker->tasks.front());
        invoker->tasks.pop_front();
        lock.unlock();
        task(rt);
        rt.drainMicrotasks();
      }
    } catch (const jsi::JSError &error) {
      std::cerr << "uncaught JS error: " << error.getMessage() << "\n" << error.getStack() << std::endl;
      return 1;
    }
    // Teardown, as a reload does it: work still queued for the JS thread is
    // dropped, then the runtime goes, and with it the module and its worker.
    std::lock_guard<std::mutex> lock(invoker->mutex);
    std::cout << "tearing down with " << invoker->tasks.size() << " JS task(s) unrun" << std::endl;
    invoker->tasks.clear();
  }
  std::cout << "runtime, module and Botlish worker torn down" << std::endl;
  return 0;
}
