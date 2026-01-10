#pragma once
#include <iostream>
#include <cassert>
#include <cstring>

namespace TestFreeCustom {
   
   // Helper function to reset memory state
   void reset_memory() {
      MEMLOG_USED_COUNT = 0;
      memset(MEMLOG, 0, MEMLOG_LEN * sizeof(int));
   }

   // Helper to print memory state
   void print_memory_state(const char* label) {
      std::cout << label << std::endl;
      std::cout << "  MEMLOG entries: " << (MEMLOG_USED_COUNT / 2) << std::endl;
      for (int i = 0; i < MEMLOG_USED_COUNT; i += 2) {
         std::cout << "    [" << (i/2) << "] addr=" << MEMLOG[i] 
                   << ", size=" << MEMLOG[i+1] << std::endl;
      }
   }

   // Test 1: Free the only allocation
   void test_free_single() {
      std::cout << "\n=== Test 1: Free single allocation ===" << std::endl;
      reset_memory();

      int ptr = malloc_custom(64);
      print_memory_state("After allocation");
      
      free_custom(ptr);
      print_memory_state("After free");

      assert(MEMLOG_USED_COUNT == 0);
      std::cout << "PASSED" << std::endl;
   }

   // Test 2: Free first of multiple allocations
   void test_free_first() {
      std::cout << "\n=== Test 2: Free first allocation ===" << std::endl;
      reset_memory();

      int ptr1 = malloc_custom(64);
      int ptr2 = malloc_custom(128);
      int ptr3 = malloc_custom(32);
      print_memory_state("After 3 allocations");
      
      free_custom(ptr1);
      print_memory_state("After freeing first");

      assert(MEMLOG_USED_COUNT == 4); // 2 allocations left
      assert(MEMLOG[0] == ptr2);
      assert(MEMLOG[2] == ptr3);
      std::cout << "PASSED" << std::endl;
   }

   // Test 3: Free middle allocation
   void test_free_middle() {
      std::cout << "\n=== Test 3: Free middle allocation ===" << std::endl;
      reset_memory();

      int ptr1 = malloc_custom(64);
      int ptr2 = malloc_custom(128);
      int ptr3 = malloc_custom(32);
      print_memory_state("After 3 allocations");
      
      free_custom(ptr2);
      print_memory_state("After freeing middle");

      assert(MEMLOG_USED_COUNT == 4);
      assert(MEMLOG[0] == ptr1);
      assert(MEMLOG[2] == ptr3);
      std::cout << "PASSED" << std::endl;
   }

   // Test 4: Free last allocation
   void test_free_last() {
      std::cout << "\n=== Test 4: Free last allocation ===" << std::endl;
      reset_memory();

      int ptr1 = malloc_custom(64);
      int ptr2 = malloc_custom(128);
      int ptr3 = malloc_custom(32);
      print_memory_state("After 3 allocations");
      
      free_custom(ptr3);
      print_memory_state("After freeing last");

      assert(MEMLOG_USED_COUNT == 4);
      assert(MEMLOG[0] == ptr1);
      assert(MEMLOG[2] == ptr2);
      std::cout << "PASSED" << std::endl;
   }

   // Test 5: Free all allocations in order
   void test_free_all_sequential() {
      std::cout << "\n=== Test 5: Free all allocations sequentially ===" << std::endl;
      reset_memory();

      int ptr1 = malloc_custom(64);
      int ptr2 = malloc_custom(128);
      int ptr3 = malloc_custom(32);
      print_memory_state("After 3 allocations");
      
      free_custom(ptr1);
      free_custom(ptr2);
      free_custom(ptr3);
      print_memory_state("After freeing all");

      assert(MEMLOG_USED_COUNT == 0);
      std::cout << "PASSED" << std::endl;
   }

   // Test 6: Free all allocations in reverse order
   void test_free_all_reverse() {
      std::cout << "\n=== Test 6: Free all allocations in reverse ===" << std::endl;
      reset_memory();

      int ptr1 = malloc_custom(64);
      int ptr2 = malloc_custom(128);
      int ptr3 = malloc_custom(32);
      print_memory_state("After 3 allocations");
      
      free_custom(ptr3);
      free_custom(ptr2);
      free_custom(ptr1);
      print_memory_state("After freeing all");

      assert(MEMLOG_USED_COUNT == 0);
      std::cout << "PASSED" << std::endl;
   }

   // Test 7: Free invalid pointer (not allocated)
   void test_free_invalid() {
      std::cout << "\n=== Test 7: Free invalid pointer ===" << std::endl;
      reset_memory();

      int ptr1 = malloc_custom(64);
      int initial_count = MEMLOG_USED_COUNT;
      print_memory_state("After allocation");
      
      free_custom(99999); // Invalid pointer
      print_memory_state("After freeing invalid pointer");

      assert(MEMLOG_USED_COUNT == initial_count); // Should not change
      std::cout << "PASSED" << std::endl;
   }

   // Test 8: Free and reallocate
   void test_free_and_realloc() {
      std::cout << "\n=== Test 8: Free and reallocate ===" << std::endl;
      reset_memory();

      int ptr1 = malloc_custom(100);
      int ptr2 = malloc_custom(200);
      int ptr3 = malloc_custom(50);
      print_memory_state("After 3 allocations");
      
      free_custom(ptr2); // Free middle allocation
      print_memory_state("After freeing middle");
      
      int ptr4 = malloc_custom(150); // Should fit in freed space
      print_memory_state("After new allocation");

      assert(MEMLOG_USED_COUNT == 6); // 3 allocations
      assert(ptr4 == ptr2); // Should reuse freed space
      std::cout << "PASSED" << std::endl;
   }

   // Test 9: Double free (edge case)
   void test_double_free() {
      std::cout << "\n=== Test 9: Double free ===" << std::endl;
      reset_memory();

      int ptr = malloc_custom(64);
      print_memory_state("After allocation");
      
      free_custom(ptr);
      int count_after_first = MEMLOG_USED_COUNT;
      print_memory_state("After first free");
      
      free_custom(ptr); // Double free
      print_memory_state("After second free");

      assert(MEMLOG_USED_COUNT == count_after_first); // Should not change
      std::cout << "PASSED - Double free handled gracefully" << std::endl;
   }

   // Test 10: Free with zero pointer
   void test_free_zero() {
      std::cout << "\n=== Test 10: Free zero pointer ===" << std::endl;
      reset_memory();

      int ptr = malloc_custom(64);
      int initial_count = MEMLOG_USED_COUNT;
      
      free_custom(0);

      assert(MEMLOG_USED_COUNT == initial_count); // Should not change
      std::cout << "PASSED" << std::endl;
   }

   // Run all tests
   void run_all_tests() {
      std::cout << "\n===========================================" << std::endl;
      std::cout << "Running free_custom Tests" << std::endl;
      std::cout << "===========================================" << std::endl;

      try {
         test_free_single();
         test_free_first();
         test_free_middle();
         test_free_last();
         test_free_all_sequential();
         test_free_all_reverse();
         test_free_invalid();
         test_free_and_realloc();
         test_double_free();
         test_free_zero();

         std::cout << "\n===========================================" << std::endl;
         std::cout << "ALL FREE TESTS PASSED!" << std::endl;
         std::cout << "===========================================" << std::endl;
      } catch (const std::exception& e) {
         std::cout << "\n===========================================" << std::endl;
         std::cout << "TEST FAILED: " << e.what() << std::endl;
         std::cout << "===========================================" << std::endl;
      }
   }
}
