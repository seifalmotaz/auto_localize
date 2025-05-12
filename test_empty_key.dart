import 'dart:io';
import 'package:auto_localize/auto_localize.dart';

void main() async {
  // Create a test file with an empty key
  final testDir = Directory('test_empty_key_dir');
  if (await testDir.exists()) {
    await testDir.delete(recursive: true);
  }
  await testDir.create();
  
  final libDir = Directory('${testDir.path}/lib');
  await libDir.create();
  
  // Create a test file with a Text widget that would generate an empty key
  final testFile = File('${libDir.path}/test_file.dart');
  await testFile.writeAsString('''
import 'package:flutter/material.dart';

class TestWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // This should be skipped (empty key)
          Text("!@#\$%^&*()"),
          // This should be processed (valid key)
          Text("Hello World"),
        ],
      ),
    );
  }
}
''');

  // Run the localization process
  print('Running localization on test directory...');
  await localize(
    projectPath: testDir.path,
    lang: 'en',
    packageName: 'getx',
  );
  
  // Check the generated JSON file
  final jsonFile = File('${testDir.path}/assets/lang/lang_en.json');
  if (await jsonFile.exists()) {
    final content = await jsonFile.readAsString();
    print('\nGenerated JSON content:');
    print(content);
    
    // Verify that only "hello_world" key exists and no empty key was created
    if (content.contains('key_')) {
      print('\n❌ TEST FAILED: Empty key was created!');
    } else if (content.contains('hello_world')) {
      print('\n✅ TEST PASSED: Only valid keys were created!');
    } else {
      print('\n⚠️ TEST INCONCLUSIVE: No keys were created!');
    }
  } else {
    print('\n⚠️ No JSON file was generated!');
  }
  
  // Clean up
  await testDir.delete(recursive: true);
}
