#pragma once
#include <iostream>
#include <cassert>
#include <cstring>

// AI GENERATED TESTS 

namespace TestMallocCustom {
   
   // Helper function to reset memory state
   void reset_memory() {
      MEMLOG_USED_COUNT = 0;
      memset(MEMLOG, 0, MEMLOG_LEN * sizeof(int));
   }

   // Helper to print memory state
   void print_memory_state(const char* label) {
      std::cout << label << std::endl;
      std::cout << "  MEM base address: " << (int)MEM << std::endl;
      std::cout << "  MEMLOG entries: " << (MEMLOG_USED_COUNT / 2) << std::endl;
      for (int i = 0; i < MEMLOG_USED_COUNT; i += 2) {
         std::cout << "    [" << (i/2) << "] addr=" << MEMLOG[i] 
                   << ", size=" << MEMLOG[i+1] << std::endl;
      }
   }

   // Test 1: First allocation in empty memory
   void test_first_allocation() {
      std::cout << "\n=== Test 1: First allocation ===" << std::endl;
      reset_memory();

      int ptr = malloc_custom(64);
      print_memory_state("After first allocation");

      assert(ptr != 0);
      assert(ptr == (int)MEM); // Should start at beginning of MEM
      assert(MEMLOG_USED_COUNT == 2);
      assert(MEMLOG[0] == (int)MEM);
      assert(MEMLOG[1] == 64);
      
      std::cout << "PASSED" << std::endl;
   }

   // Test 2: Multiple sequential allocations
   void test_sequential_allocations() {
      std::cout << "\n=== Test 2: Sequential allocations ===" << std::endl;
      reset_memory();

      int ptr1 = malloc_custom(64);
      int ptr2 = malloc_custom(128);
      int ptr3 = malloc_custom(32);
      print_memory_state("After 3 allocations");

      assert(ptr1 == (int)MEM);
      assert(ptr2 == (int)MEM + 64);
      assert(ptr3 == (int)MEM + 64 + 128);
      assert(MEMLOG_USED_COUNT == 6);
      
      std::cout << "PASSED" << std::endl;
   }

   // Test 3: Zero size allocation
   void test_zero_size() {
      std::cout << "\n=== Test 3: Zero size allocation ===" << std::endl;
      reset_memory();

      int ptr = malloc_custom(0);
      print_memory_state("After zero size allocation");

      assert(ptr == 0); // Should return 0 for zero size
      assert(MEMLOG_USED_COUNT == 0); // Should not log anything
      
      std::cout << "PASSED" << std::endl;
   }

   // Test 4: Allocation too large
   void test_allocation_too_large() {
      std::cout << "\n=== Test 4: Allocation too large ===" << std::endl;
      reset_memory();

      int ptr = malloc_custom(MEM_LEN + 1);
      print_memory_state("After oversized allocation");

      assert(ptr == 0); // Should fail
      assert(MEMLOG_USED_COUNT == 0);
      
      std::cout << "PASSED" << std::endl;
   }

   // Test 5: Fill entire memory
   void test_fill_memory() {
      std::cout << "\n=== Test 5: Fill entire memory ===" << std::endl;
      reset_memory();

      int ptr1 = malloc_custom(512);
      int ptr2 = malloc_custom(512);
      int ptr3 = malloc_custom(1); // Should fail
      print_memory_state("After filling memory");

      assert(ptr1 == (int)MEM);
      assert(ptr2 == (int)MEM + 512);
      assert(ptr3 == 0); // No space left
      
      std::cout << "PASSED" << std::endl;
   }

   // Test 6: Exact fit
   void test_exact_fit() {
      std::cout << "\n=== Test 6: Exact fit ===" << std::endl;
      reset_memory();

      int ptr = malloc_custom(MEM_LEN);
      print_memory_state("After exact fit allocation");

      assert(ptr == (int)MEM);
      assert(MEMLOG_USED_COUNT == 2);
      
      std::cout << "PASSED" << std::endl;
   }

   // Test 7: Address ordering check
   void test_address_ordering() {
      std::cout << "\n=== Test 7: Address ordering ===" << std::endl;
      reset_memory();

      int ptr1 = malloc_custom(100);
      int ptr2 = malloc_custom(200);
      int ptr3 = malloc_custom(50);

      // Check that addresses in MEMLOG are in ascending order
      for (int i = 0; i < MEMLOG_USED_COUNT - 2; i += 2) {
         assert(MEMLOG[i] < MEMLOG[i + 2]);
      }
      
      std::cout << "PASSED - All addresses in ascending order" << std::endl;
   }

   // Run all tests
   void run_all_tests() {
      std::cout << "\n===========================================" << std::endl;
      std::cout << "Running malloc_custom Tests" << std::endl;
      std::cout << "===========================================" << std::endl;

      try {
         test_first_allocation();
         test_sequential_allocations();
         test_zero_size();
         test_allocation_too_large();
         test_fill_memory();
         test_exact_fit();
         test_address_ordering();

         std::cout << "\n===========================================" << std::endl;
         std::cout << "ALL MALLOC TESTS PASSED!" << std::endl;
         std::cout << "===========================================" << std::endl;
      } catch (const std::exception& e) {
         std::cout << "\n===========================================" << std::endl;
         std::cout << "TEST FAILED: " << e.what() << std::endl;
         std::cout << "===========================================" << std::endl;
      }
   }
}
