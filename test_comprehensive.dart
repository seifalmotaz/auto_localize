import 'dart:io';
import 'package:auto_localize/auto_localize.dart';

void main() async {
  // Create a test file with various scenarios
  final testDir = Directory('test_comprehensive_dir');
  if (await testDir.exists()) {
    await testDir.delete(recursive: true);
  }
  await testDir.create();
  
  final libDir = Directory('${testDir.path}/lib');
  await libDir.create();
  
  // Create a test file with various Text widget scenarios
  final testFile = File('${libDir.path}/test_file.dart');
  await testFile.writeAsString('''
import 'package:flutter/material.dart';

class TestWidget extends StatelessWidget {
  final String name = "John";
  final int count = 42;
  final String empty = "";
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Case 1: Normal text (should be processed)
          Text("Hello World"),
          
          // Case 2: Text with variables (should be processed)
          Text("Hello \$name"),
          
          // Case 3: Text with complex variables (should be processed)
          Text("You have \${count} items"),
          
          // Case 4: Only variables (should be skipped)
          Text("\${name}"),
          
          // Case 5: Multiple variables only (should be skipped)
          Text("\$name \${count}"),
          
          // Case 6: Empty string (should be skipped)
          Text(""),
          
          // Case 7: Only special characters (should be skipped)
          Text("@#\$%^&*()"),
          
          // Case 8: Variable with empty value (should be processed)
          Text("Empty: \${empty}"),
          
          // Case 9: Complex expression (should be processed)
          Text("Result: \${count * 2}"),
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
    
    // Check which keys were created
    final shouldExist = ['hello_world', 'hello', 'you_have', 'empty', 'result'];
    final shouldNotExist = ['key_', 'name', 'count'];
    
    bool allExpectedKeysExist = true;
    bool noUnexpectedKeysExist = true;
    
    for (final key in shouldExist) {
      if (!content.contains(key)) {
        print('\n❌ Expected key "$key" was not created!');
        allExpectedKeysExist = false;
      }
    }
    
    for (final key in shouldNotExist) {
      if (content.contains('"$key"')) {
        print('\n❌ Unexpected key "$key" was created!');
        noUnexpectedKeysExist = false;
      }
    }
    
    if (allExpectedKeysExist && noUnexpectedKeysExist) {
      print('\n✅ TEST PASSED: All expected keys were created and no unexpected keys were created!');
    } else {
      print('\n❌ TEST FAILED: Some expected keys were missing or unexpected keys were created!');
    }
  } else {
    print('\n⚠️ No JSON file was generated!');
  }
  
  // Clean up
  await testDir.delete(recursive: true);
}
