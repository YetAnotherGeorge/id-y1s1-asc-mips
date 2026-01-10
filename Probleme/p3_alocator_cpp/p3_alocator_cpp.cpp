#include <iostream>

#pragma region MemoryManagement
int MEM_LEN = 1024;
void* MEM = malloc(MEM_LEN); // bytes

int MEMLOG_LEN = 512;
int MEMLOG_USED_COUNT = 0;
// structura va fi: [start1, size1, start2, size2, ...]
// va fi tinut in ordine crescatoare dupa valoarea adresei alocate
int* MEMLOG
= (int*)malloc(MEMLOG_LEN * sizeof(int));
#pragma endregion

/// <summary>
/// Inserts a memory allocation record into MEMLOG in ascending order based on mem_addr.
/// </summary>
/// <param name="mem_addr"></param>
/// <param name="alloc_size"></param>
/// <returns></returns>
bool log_insert_ordered(int mem_addr, int alloc_size) {
   if (MEMLOG_USED_COUNT + 2 > MEMLOG_LEN) return false; // no space in log

   // Find insert position
   int ins_pos = MEMLOG_USED_COUNT;
   for (int i = 0; i < MEMLOG_USED_COUNT; i += 2) {
      int a = MEMLOG[i];  // addr
      //int s = MEMLOG[i + 1]; // alloc size

      if (mem_addr <= a) { // insert here
         ins_pos = i;
         break;
      }
   }

   // Insert at ins_pos
   if (ins_pos < MEMLOG_USED_COUNT) {
      // shift MEMLOG_USED_COUNT -> 2 from index i
      for (int j = MEMLOG_USED_COUNT - 1; j >= ins_pos; j--) {
         MEMLOG[j + 2] = MEMLOG[j];
      }
   }

   MEMLOG[ins_pos] = mem_addr;
   MEMLOG[ins_pos + 1] = alloc_size;
   MEMLOG_USED_COUNT += 2;
   return true;
}

// alloc_sz in bytes
int malloc_custom(int alloc_bytes) {
   if (alloc_bytes <= 0) return 0;
   if (alloc_bytes > MEM_LEN) return 0;

   int alloc_addr = (int)MEM;
   int alloc_addr_end = alloc_addr + alloc_bytes;

   // Find a free block of size alloc_sz
   for (int i = 0; i < MEMLOG_USED_COUNT; i += 2) {
      int a = MEMLOG[i]; // addr
      int s = MEMLOG[i + 1]; // alloc size

      if (alloc_addr_end <= a) {
         break; // found space before this block
      }
      alloc_addr = a + s; // move to end of this block
      alloc_addr_end = alloc_addr + alloc_bytes;
   }

   // Check if we have enough memory
   if ((alloc_addr_end - (int)MEM) > MEM_LEN) {
      return 0; // not enough memory
   }
   bool could_insert = log_insert_ordered(alloc_addr, alloc_bytes);
   if (!could_insert)
      return 0; // could not log allocation
   return alloc_addr;
}

void free_custom(int ptr) {
   for (int i = 0; i < MEMLOG_USED_COUNT; i += 2) {
      int a = MEMLOG[i]; // addr
      if (a == ptr) {
         // remove this entry
         for (int j = i; j < MEMLOG_USED_COUNT - 2; j++) {
            MEMLOG[j] = MEMLOG[j + 2];
         }
         MEMLOG_USED_COUNT -= 2;
         return;
      }
   }
}
void compact_custom() {
   int apu = (int)MEM; // address prev usable
   for (int i = 0; i < MEMLOG_USED_COUNT; i += 2) {
      int a = MEMLOG[i]; // addr
      int s = MEMLOG[i + 1]; // alloc size

      if (apu < a) { // move block down
         for (int j = 0; j < s; j++) {
            // move a + j to apu + j
            char* addr_from = (char*)(a + j);
            char* addr_to = (char*)(apu + j);
            *addr_to = *addr_from;
         }
         MEMLOG[i] = apu;
      }
      apu += s; // update apu to end of this block
   }
}

#include "tests_log_ins_ordered.h"
#include "tests_malloc_custom.h"
#include "tests_free_custom.h"
#include "tests_compact_custom.h"

int main() {
   /*TestLogInsertOrdered::run_all_tests();
   TestMallocCustom::run_all_tests();
   TestFreeCustom::run_all_tests();*/
   TestCompactCustom::run_all_tests();

   return 0;
}
