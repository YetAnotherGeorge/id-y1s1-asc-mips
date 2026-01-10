#pragma once
#include <iostream>
#include <cassert>
#include <cstring>

// AI GENERATED TESTS FOR log_insert_ordered FUNCTION

namespace TestLogInsertOrdered {
   // Helper function to reset the memory log for testing
   void reset_memlog() {
      MEMLOG_USED_COUNT = 0;
      memset(MEMLOG, 0, MEMLOG_LEN * sizeof(int));
   }

   // Helper function to print the current state of MEMLOG
   void print_memlog(const char* label) {
      std::cout << label << ": [";
      for (int i = 0; i < MEMLOG_USED_COUNT; i += 2) {
         std::cout << "(" << MEMLOG[i] << "," << MEMLOG[i + 1] << ")";
         if (i + 2 < MEMLOG_USED_COUNT) std::cout << ", ";
      }
      std::cout << "]" << std::endl;
   }

   // Helper function to verify MEMLOG contents
   bool verify_memlog(int expected[][2], int count) {
      if (MEMLOG_USED_COUNT != count * 2) {
         std::cout << "ERROR: Expected count " << count * 2 << ", got " << MEMLOG_USED_COUNT << std::endl;
         return false;
      }
      for (int i = 0; i < count; i++) {
         if (MEMLOG[i * 2] != expected[i][0] || MEMLOG[i * 2 + 1] != expected[i][1]) {
            std::cout << "ERROR: At index " << i << " expected (" << expected[i][0] << ","
               << expected[i][1] << "), got (" << MEMLOG[i * 2] << ","
               << MEMLOG[i * 2 + 1] << ")" << std::endl;
            return false;
         }
      }
      return true;
   }

   // Test 1: First insert into empty log
   void test_first_insert() {
      std::cout << "\n=== Test 1: First insert into empty log ===" << std::endl;
      reset_memlog();

      bool result = log_insert_ordered(100, 50);
      print_memlog("After insert");

      assert(result == true);
      int expected[][2] = { {100, 50} };
      assert(verify_memlog(expected, 1));
      std::cout << "PASSED" << std::endl;
   }

   // Test 2: Insert at the end (address larger than last)
   void test_insert_at_end() {
      std::cout << "\n=== Test 2: Insert at the end ===" << std::endl;
      reset_memlog();

      log_insert_ordered(100, 50);
      log_insert_ordered(200, 30);
      log_insert_ordered(300, 40);
      print_memlog("After 3 inserts");

      int expected[][2] = { {100, 50}, {200, 30}, {300, 40} };
      assert(verify_memlog(expected, 3));
      std::cout << "PASSED" << std::endl;
   }

   // Test 3: Insert at the beginning (address smaller than first)
   void test_insert_at_beginning() {
      std::cout << "\n=== Test 3: Insert at the beginning ===" << std::endl;
      reset_memlog();

      log_insert_ordered(200, 50);
      log_insert_ordered(100, 30);
      print_memlog("After insert at beginning");

      int expected[][2] = { {100, 30}, {200, 50} };
      assert(verify_memlog(expected, 2));
      std::cout << "PASSED" << std::endl;
   }

   // Test 4: Insert in the middle
   void test_insert_in_middle() {
      std::cout << "\n=== Test 4: Insert in the middle ===" << std::endl;
      reset_memlog();

      log_insert_ordered(100, 20);
      log_insert_ordered(300, 30);
      log_insert_ordered(200, 25);
      print_memlog("After insert in middle");

      int expected[][2] = { {100, 20}, {200, 25}, {300, 30} };
      assert(verify_memlog(expected, 3));
      std::cout << "PASSED" << std::endl;
   }

   // Test 5: Multiple inserts with mixed order
   void test_mixed_order_inserts() {
      std::cout << "\n=== Test 5: Multiple inserts with mixed order ===" << std::endl;
      reset_memlog();

      log_insert_ordered(500, 10);
      log_insert_ordered(100, 20);
      log_insert_ordered(300, 30);
      log_insert_ordered(200, 15);
      log_insert_ordered(400, 25);
      print_memlog("After mixed order inserts");

      int expected[][2] = { {100, 20}, {200, 15}, {300, 30}, {400, 25}, {500, 10} };
      assert(verify_memlog(expected, 5));
      std::cout << "PASSED" << std::endl;
   }

   // Test 6: Duplicate addresses (edge case)
   void test_duplicate_addresses() {
      std::cout << "\n=== Test 6: Duplicate addresses ===" << std::endl;
      reset_memlog();

      log_insert_ordered(100, 20);
      log_insert_ordered(100, 30);
      print_memlog("After duplicate address insert");

      // Both should be inserted, order depends on implementation
      assert(MEMLOG_USED_COUNT == 4);
      std::cout << "PASSED" << std::endl;
   }

   // Test 7: Fill log to capacity
   void test_log_capacity() {
      std::cout << "\n=== Test 7: Log capacity test ===" << std::endl;
      reset_memlog();

      int inserts = 0;
      for (int i = 0; i < MEMLOG_LEN / 2; i++) {
         if (log_insert_ordered(i * 100, 50)) {
            inserts++;
         } else {
            break;
         }
      }

      std::cout << "Successfully inserted " << inserts << " entries" << std::endl;
      assert(MEMLOG_USED_COUNT <= MEMLOG_LEN);

      // Try one more insert - should fail
      bool result = log_insert_ordered(99999, 50);
      assert(result == false);
      std::cout << "PASSED - correctly rejected insert when full" << std::endl;
   }

   // Test 8: Sequential addresses
   void test_sequential_addresses() {
      std::cout << "\n=== Test 8: Sequential addresses ===" << std::endl;
      reset_memlog();

      log_insert_ordered(1000, 10);
      log_insert_ordered(1010, 10);
      log_insert_ordered(1020, 10);
      print_memlog("After sequential inserts");

      int expected[][2] = { {1000, 10}, {1010, 10}, {1020, 10} };
      assert(verify_memlog(expected, 3));
      std::cout << "PASSED" << std::endl;
   }

   // Test 9: Reverse order inserts
   void test_reverse_order() {
      std::cout << "\n=== Test 9: Reverse order inserts ===" << std::endl;
      reset_memlog();

      log_insert_ordered(500, 10);
      log_insert_ordered(400, 10);
      log_insert_ordered(300, 10);
      log_insert_ordered(200, 10);
      log_insert_ordered(100, 10);
      print_memlog("After reverse order inserts");

      int expected[][2] = { {100, 10}, {200, 10}, {300, 10}, {400, 10}, {500, 10} };
      assert(verify_memlog(expected, 5));
      std::cout << "PASSED" << std::endl;
   }

   // Test 10: Edge case - insert with zero size
   void test_zero_size() {
      std::cout << "\n=== Test 10: Zero size allocation ===" << std::endl;
      reset_memlog();

      log_insert_ordered(100, 0);
      print_memlog("After zero size insert");

      int expected[][2] = { {100, 0} };
      assert(verify_memlog(expected, 1));
      std::cout << "PASSED" << std::endl;
   }

   // Run all tests
   void run_all_tests() {
      std::cout << "\n===========================================" << std::endl;
      std::cout << "Running log_insert_ordered Tests" << std::endl;
      std::cout << "===========================================" << std::endl;

      try {
         test_first_insert();
         test_insert_at_end();
         test_insert_at_beginning();
         test_insert_in_middle();
         test_mixed_order_inserts();
         test_duplicate_addresses();
         test_log_capacity();
         test_sequential_addresses();
         test_reverse_order();
         test_zero_size();

         std::cout << "\n===========================================" << std::endl;
         std::cout << "ALL TESTS PASSED!" << std::endl;
         std::cout << "===========================================" << std::endl;
      } catch (const std::exception& e) {
         std::cout << "\n===========================================" << std::endl;
         std::cout << "TEST FAILED: " << e.what() << std::endl;
         std::cout << "===========================================" << std::endl;
      }
   }

}