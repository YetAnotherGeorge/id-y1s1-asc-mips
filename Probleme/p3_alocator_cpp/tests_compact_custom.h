#pragma once
#include <iostream>
#include <cassert>
#include <cstring>

// AI GENERATED TESTS 

namespace TestCompactCustom {
   
   // Helper function to reset memory state
   void reset_memory() {
      MEMLOG_USED_COUNT = 0;
      memset(MEMLOG, 0, MEMLOG_LEN * sizeof(int));
      memset(MEM, 0, MEM_LEN);
   }

   // Helper to print memory state
   void print_memory_state(const char* label) {
      std::cout << label << std::endl;
      std::cout << "  MEM base address: " << (int)MEM << std::endl;
      std::cout << "  MEMLOG entries: " << (MEMLOG_USED_COUNT / 2) << std::endl;
      for (int i = 0; i < MEMLOG_USED_COUNT; i += 2) {
         std::cout << "    [" << (i/2) << "] addr=" << MEMLOG[i] 
                   << ", size=" << MEMLOG[i+1] 
                   << ", offset=" << (MEMLOG[i] - (int)MEM) << std::endl;
      }
   }

   // Helper to write pattern to memory
   void write_pattern(int addr, int size, char pattern) {
      char* ptr = (char*)addr;
      for (int i = 0; i < size; i++) {
         ptr[i] = pattern + (i % 26); // Create unique pattern
      }
   }

   // Helper to verify pattern in memory
   bool verify_pattern(int addr, int size, char pattern) {
      char* ptr = (char*)addr;
      for (int i = 0; i < size; i++) {
         if (ptr[i] != (char)(pattern + (i % 26))) {
            std::cout << "    Pattern mismatch at offset " << i 
                     << ": expected " << (int)(pattern + (i % 26)) 
                     << ", got " << (int)ptr[i] << std::endl;
            return false;
         }
      }
      return true;
   }

   // Test 1: Compact with no allocations
   void test_compact_empty() {
      std::cout << "\n=== Test 1: Compact with no allocations ===" << std::endl;
      reset_memory();

      compact_custom();
      print_memory_state("After compact");

      assert(MEMLOG_USED_COUNT == 0);
      std::cout << "PASSED" << std::endl;
   }

   // Test 2: Compact with single allocation (no gaps)
   void test_compact_single() {
      std::cout << "\n=== Test 2: Compact with single allocation ===" << std::endl;
      reset_memory();

      int ptr = malloc_custom(64);
      write_pattern(ptr, 64, 'A');
      print_memory_state("Before compact");

      compact_custom();
      print_memory_state("After compact");

      assert(MEMLOG_USED_COUNT == 2);
      assert(MEMLOG[0] == (int)MEM);
      assert(MEMLOG[1] == 64);
      assert(verify_pattern(MEMLOG[0], 64, 'A'));
      std::cout << "PASSED" << std::endl;
   }

   // Test 3: Compact with no gaps (sequential allocations)
   void test_compact_no_gaps() {
      std::cout << "\n=== Test 3: Compact with no gaps ===" << std::endl;
      reset_memory();

      int ptr1 = malloc_custom(64);
      int ptr2 = malloc_custom(128);
      int ptr3 = malloc_custom(32);
      write_pattern(ptr1, 64, 'A');
      write_pattern(ptr2, 128, 'B');
      write_pattern(ptr3, 32, 'C');
      print_memory_state("Before compact");

      compact_custom();
      print_memory_state("After compact");

      // No changes should occur
      assert(MEMLOG_USED_COUNT == 6);
      assert(MEMLOG[0] == (int)MEM);
      assert(MEMLOG[2] == (int)MEM + 64);
      assert(MEMLOG[4] == (int)MEM + 64 + 128);
      assert(verify_pattern(MEMLOG[0], 64, 'A'));
      assert(verify_pattern(MEMLOG[2], 128, 'B'));
      assert(verify_pattern(MEMLOG[4], 32, 'C'));
      std::cout << "PASSED" << std::endl;
   }

   // Test 4: Compact with gap at beginning
   void test_compact_gap_at_beginning() {
      std::cout << "\n=== Test 4: Compact with gap at beginning ===" << std::endl;
      reset_memory();

      int ptr1 = malloc_custom(64);
      int ptr2 = malloc_custom(128);
      int ptr3 = malloc_custom(32);
      write_pattern(ptr1, 64, 'A');
      write_pattern(ptr2, 128, 'B');
      write_pattern(ptr3, 32, 'C');
      
      free_custom(ptr1); // Create gap at beginning
      print_memory_state("After freeing first allocation");

      compact_custom();
      print_memory_state("After compact");

      // ptr2 and ptr3 should move to beginning
      assert(MEMLOG_USED_COUNT == 4);
      assert(MEMLOG[0] == (int)MEM);
      assert(MEMLOG[1] == 128);
      assert(MEMLOG[2] == (int)MEM + 128);
      assert(MEMLOG[3] == 32);
      assert(verify_pattern(MEMLOG[0], 128, 'B'));
      assert(verify_pattern(MEMLOG[2], 32, 'C'));
      std::cout << "PASSED" << std::endl;
   }

   // Test 5: Compact with gap in middle
   void test_compact_gap_in_middle() {
      std::cout << "\n=== Test 5: Compact with gap in middle ===" << std::endl;
      reset_memory();

      int ptr1 = malloc_custom(64);
      int ptr2 = malloc_custom(128);
      int ptr3 = malloc_custom(32);
      write_pattern(ptr1, 64, 'A');
      write_pattern(ptr2, 128, 'B');
      write_pattern(ptr3, 32, 'C');
      
      free_custom(ptr2); // Create gap in middle
      print_memory_state("After freeing middle allocation");

      compact_custom();
      print_memory_state("After compact");

      // ptr3 should move to fill gap
      assert(MEMLOG_USED_COUNT == 4);
      assert(MEMLOG[0] == (int)MEM);
      assert(MEMLOG[1] == 64);
      assert(MEMLOG[2] == (int)MEM + 64);
      assert(MEMLOG[3] == 32);
      assert(verify_pattern(MEMLOG[0], 64, 'A'));
      assert(verify_pattern(MEMLOG[2], 32, 'C'));
      std::cout << "PASSED" << std::endl;
   }

   // Test 6: Compact with gap at end
   void test_compact_gap_at_end() {
      std::cout << "\n=== Test 6: Compact with gap at end ===" << std::endl;
      reset_memory();

      int ptr1 = malloc_custom(64);
      int ptr2 = malloc_custom(128);
      int ptr3 = malloc_custom(32);
      write_pattern(ptr1, 64, 'A');
      write_pattern(ptr2, 128, 'B');
      write_pattern(ptr3, 32, 'C');
      
      free_custom(ptr3); // Create gap at end
      print_memory_state("After freeing last allocation");

      compact_custom();
      print_memory_state("After compact");

      // No changes needed since gap is at end
      assert(MEMLOG_USED_COUNT == 4);
      assert(MEMLOG[0] == (int)MEM);
      assert(MEMLOG[2] == (int)MEM + 64);
      assert(verify_pattern(MEMLOG[0], 64, 'A'));
      assert(verify_pattern(MEMLOG[2], 128, 'B'));
      std::cout << "PASSED" << std::endl;
   }

   // Test 7: Compact with multiple gaps
   void test_compact_multiple_gaps() {
      std::cout << "\n=== Test 7: Compact with multiple gaps ===" << std::endl;
      reset_memory();

      int ptr1 = malloc_custom(50);
      int ptr2 = malloc_custom(60);
      int ptr3 = malloc_custom(70);
      int ptr4 = malloc_custom(80);
      int ptr5 = malloc_custom(90);
      write_pattern(ptr1, 50, 'A');
      write_pattern(ptr2, 60, 'B');
      write_pattern(ptr3, 70, 'C');
      write_pattern(ptr4, 80, 'D');
      write_pattern(ptr5, 90, 'E');
      
      free_custom(ptr2); // Create first gap
      free_custom(ptr4); // Create second gap
      print_memory_state("After creating gaps");

      compact_custom();
      print_memory_state("After compact");

      // Remaining allocations should be compacted
      assert(MEMLOG_USED_COUNT == 6);
      assert(MEMLOG[0] == (int)MEM);
      assert(MEMLOG[1] == 50);
      assert(MEMLOG[2] == (int)MEM + 50);
      assert(MEMLOG[3] == 70);
      assert(MEMLOG[4] == (int)MEM + 50 + 70);
      assert(MEMLOG[5] == 90);
      assert(verify_pattern(MEMLOG[0], 50, 'A'));
      assert(verify_pattern(MEMLOG[2], 70, 'C'));
      assert(verify_pattern(MEMLOG[4], 90, 'E'));
      std::cout << "PASSED" << std::endl;
   }

   // Test 8: Compact and allocate after
   void test_compact_and_allocate() {
      std::cout << "\n=== Test 8: Compact and allocate after ===" << std::endl;
      reset_memory();

      int ptr1 = malloc_custom(200);
      int ptr2 = malloc_custom(200);
      int ptr3 = malloc_custom(200);
      write_pattern(ptr1, 200, 'A');
      write_pattern(ptr2, 200, 'B');
      write_pattern(ptr3, 200, 'C');
      
      free_custom(ptr1);
      free_custom(ptr3);
      print_memory_state("After freeing ptr1 and ptr3");

      compact_custom();
      print_memory_state("After compact");

      // Should now have space for larger allocation
      int ptr4 = malloc_custom(400);
      print_memory_state("After new allocation");

      assert(ptr4 != 0); // Should succeed
      assert(ptr4 == (int)MEM + 200); // After compacted ptr2
      assert(verify_pattern(MEMLOG[0], 200, 'B'));
      std::cout << "PASSED" << std::endl;
   }

   // Test 9: Compact preserves data integrity
   void test_compact_data_integrity() {
      std::cout << "\n=== Test 9: Compact preserves data integrity ===" << std::endl;
      reset_memory();

      // Allocate and write specific patterns
      int ptr1 = malloc_custom(100);
      int ptr2 = malloc_custom(100);
      int ptr3 = malloc_custom(100);
      int ptr4 = malloc_custom(100);
      
      // Write unique data to each block
      for (int i = 0; i < 100; i++) {
         ((char*)ptr1)[i] = (char)(i & 0xFF);
         ((char*)ptr2)[i] = (char)((i + 100) & 0xFF);
         ((char*)ptr3)[i] = (char)((i + 200) & 0xFF);
         ((char*)ptr4)[i] = (char)((i + 300) & 0xFF);
      }
      
      free_custom(ptr1);
      free_custom(ptr3);
      print_memory_state("After freeing ptr1 and ptr3");

      compact_custom();
      print_memory_state("After compact");

      // Verify data integrity
      char* new_ptr2 = (char*)MEMLOG[0];
      char* new_ptr4 = (char*)MEMLOG[2];
      
      bool ptr2_ok = true, ptr4_ok = true;
      for (int i = 0; i < 100; i++) {
         if (new_ptr2[i] != (char)((i + 100) & 0xFF)) ptr2_ok = false;
         if (new_ptr4[i] != (char)((i + 300) & 0xFF)) ptr4_ok = false;
      }
      
      assert(ptr2_ok);
      assert(ptr4_ok);
      std::cout << "PASSED - Data integrity preserved" << std::endl;
   }

   // Test 10: Compact with alternating allocations freed
   void test_compact_alternating() {
      std::cout << "\n=== Test 10: Compact with alternating frees ===" << std::endl;
      reset_memory();

      int ptrs[6];
      for (int i = 0; i < 6; i++) {
         ptrs[i] = malloc_custom(50);
         write_pattern(ptrs[i], 50, 'A' + i);
      }
      
      // Free alternating blocks
      free_custom(ptrs[0]);
      free_custom(ptrs[2]);
      free_custom(ptrs[4]);
      print_memory_state("After freeing alternating blocks");

      compact_custom();
      print_memory_state("After compact");

      // Should have 3 blocks, all at beginning
      assert(MEMLOG_USED_COUNT == 6);
      assert(MEMLOG[0] == (int)MEM);
      assert(MEMLOG[2] == (int)MEM + 50);
      assert(MEMLOG[4] == (int)MEM + 100);
      assert(verify_pattern(MEMLOG[0], 50, 'B'));
      assert(verify_pattern(MEMLOG[2], 50, 'D'));
      assert(verify_pattern(MEMLOG[4], 50, 'F'));
      std::cout << "PASSED" << std::endl;
   }

   // Test 11: Compact after freeing all but one
   void test_compact_one_remaining() {
      std::cout << "\n=== Test 11: Compact with one remaining allocation ===" << std::endl;
      reset_memory();

      int ptr1 = malloc_custom(100);
      int ptr2 = malloc_custom(100);
      int ptr3 = malloc_custom(100);
      int ptr4 = malloc_custom(100);
      write_pattern(ptr4, 100, 'D');
      
      free_custom(ptr1);
      free_custom(ptr2);
      free_custom(ptr3);
      print_memory_state("After freeing first 3 allocations");

      compact_custom();
      print_memory_state("After compact");

      assert(MEMLOG_USED_COUNT == 2);
      assert(MEMLOG[0] == (int)MEM);
      assert(MEMLOG[1] == 100);
      assert(verify_pattern(MEMLOG[0], 100, 'D'));
      std::cout << "PASSED" << std::endl;
   }

   // Test 12: Stress test - many small allocations
   void test_compact_many_small() {
      std::cout << "\n=== Test 12: Compact with many small allocations ===" << std::endl;
      reset_memory();

      const int NUM_ALLOCS = 20;
      int ptrs[NUM_ALLOCS];
      
      // Allocate many small blocks
      for (int i = 0; i < NUM_ALLOCS; i++) {
         ptrs[i] = malloc_custom(30);
         write_pattern(ptrs[i], 30, 'A' + (i % 26));
      }
      
      // Free every other block
      for (int i = 0; i < NUM_ALLOCS; i += 2) {
         free_custom(ptrs[i]);
      }
      print_memory_state("After freeing every other block");

      compact_custom();
      print_memory_state("After compact");

      // Verify remaining blocks are compacted
      assert(MEMLOG_USED_COUNT == 20); // 10 blocks remain
      int expected_addr = (int)MEM;
      for (int i = 0; i < 10; i++) {
         assert(MEMLOG[i * 2] == expected_addr);
         assert(MEMLOG[i * 2 + 1] == 30);
         expected_addr += 30;
      }
      std::cout << "PASSED" << std::endl;
   }

   // Run all tests
   void run_all_tests() {
      std::cout << "\n===========================================" << std::endl;
      std::cout << "Running compact_custom Tests" << std::endl;
      std::cout << "===========================================" << std::endl;

      try {
         test_compact_empty();
         test_compact_single();
         test_compact_no_gaps();
         test_compact_gap_at_beginning();
         test_compact_gap_in_middle();
         test_compact_gap_at_end();
         test_compact_multiple_gaps();
         test_compact_and_allocate();
         test_compact_data_integrity();
         test_compact_alternating();
         test_compact_one_remaining();
         test_compact_many_small();

         std::cout << "\n===========================================" << std::endl;
         std::cout << "ALL COMPACT TESTS PASSED!" << std::endl;
         std::cout << "===========================================" << std::endl;
      } catch (const std::exception& e) {
         std::cout << "\n===========================================" << std::endl;
         std::cout << "TEST FAILED: " << e.what() << std::endl;
         std::cout << "===========================================" << std::endl;
      }
   }
}
