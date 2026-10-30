//! A generation-checked handle table: the only thing Botlish ever holds of
//! a Rust object is its handle, `generation << 32 | index`, an integer.
//! A handle whose object was released is refused (stale), also after its
//! index is reused: the generation moved on.

/// Fault injection: handles are looked up by index alone.
pub const FAULT_INDEX_ONLY: u32 = 256;

pub struct Slab<T> {
    slots: Vec<(u32, Option<T>)>,
    free: Vec<u32>,
}

impl<T> Default for Slab<T> {
    fn default() -> Self {
        Slab { slots: Vec::new(), free: Vec::new() }
    }
}

pub fn index(handle: i64) -> usize {
    (handle as u64 & 0xffff_ffff) as usize
}

impl<T> Slab<T> {
    pub fn insert(&mut self, value: T) -> i64 {
        let index = match self.free.pop() {
            Some(i) => i,
            None => {
                self.slots.push((0, None));
                (self.slots.len() - 1) as u32
            }
        };
        let slot = &mut self.slots[index as usize];
        // Generations start at 1, so no handle is 0 or negative.
        slot.0 = slot.0.wrapping_add(1).max(1) & 0x7fff_ffff;
        slot.1 = Some(value);
        ((slot.0 as i64) << 32) | index as i64
    }

    fn slot(&self, handle: i64) -> Option<&(u32, Option<T>)> {
        if handle <= 0 {
            return None;
        }
        let slot = self.slots.get(index(handle))?;
        // The stale-completion control: an index-only lookup, so a stale
        // handle reaches whatever reuses its index.
        if crate::exec::fault() & FAULT_INDEX_ONLY != 0 {
            return Some(slot);
        }
        (slot.0 as i64 == (handle >> 32) & 0x7fff_ffff).then_some(slot)
    }

    pub fn get(&self, handle: i64) -> Option<&T> {
        self.slot(handle)?.1.as_ref()
    }

    pub fn get_mut(&mut self, handle: i64) -> Option<&mut T> {
        self.slot(handle)?;
        self.slots[index(handle)].1.as_mut()
    }

    pub fn remove(&mut self, handle: i64) -> Option<T> {
        self.slot(handle)?;
        let value = self.slots[index(handle)].1.take();
        if value.is_some() {
            self.free.push(index(handle) as u32);
        }
        value
    }

    pub fn len(&self) -> usize {
        self.slots.len() - self.free.len()
    }

    pub fn is_empty(&self) -> bool {
        self.len() == 0
    }

    pub fn handles(&self) -> Vec<i64> {
        self.slots
            .iter()
            .enumerate()
            .filter(|(_, s)| s.1.is_some())
            .map(|(i, s)| ((s.0 as i64) << 32) | i as i64)
            .collect()
    }
}
