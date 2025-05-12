import 'dart:io';
import 'package:auto_localize/auto_localize.dart';

void main() async {
  // Create a test file with a string that contains only variables
  final testDir = Directory('test_variables_only_dir');
  if (await testDir.exists()) {
    await testDir.delete(recursive: true);
  }
  await testDir.create();
  
  final libDir = Directory('${testDir.path}/lib');
  await libDir.create();
  
  // Create a test file with Text widgets that contain only variables
  final testFile = File('${libDir.path}/test_file.dart');
  await testFile.writeAsString('''
import 'package:flutter/material.dart';

class TestWidget extends StatelessWidget {
  final String hello = "Hello";
  final String world = "World";
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // This should be skipped (only variables)
          Text("\${hello}"),
          
          // This should be skipped (only variables)
          Text("\$world"),
          
          // This should be skipped (only variables with some formatting)
          Text("\${hello} \${world}"),
          
          // This should be processed (has text + variable)
          Text("Greeting: \${hello}"),
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
    
    // Verify that only "greeting" key exists and no keys for variable-only strings were created
    if (content.contains('hello') && !content.contains('greeting')) {
      print('\n❌ TEST FAILED: Keys were created for variable-only strings!');
    } else if (!content.contains('hello') && content.contains('greeting')) {
      print('\n✅ TEST PASSED: Only strings with text were processed!');
    } else if (!content.contains('hello') && !content.contains('greeting')) {
      print('\n⚠️ TEST INCONCLUSIVE: No keys were created!');
    } else {
      print('\n⚠️ TEST INCONCLUSIVE: Unexpected keys were created!');
    }
  } else {
    print('\n⚠️ No JSON file was generated!');
  }
  
  // Clean up
  await testDir.delete(recursive: true);
}
