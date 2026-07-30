import re
import pathlib
import sys

gradle_file = pathlib.Path("android/app/build.gradle.kts")
if not gradle_file.exists():
    gradle_file = pathlib.Path("android/app/build.gradle")
is_kts = gradle_file.suffix == ".kts"
text = gradle_file.read_text()

if is_kts:
    props_block = (
        "\n"
        "    val keystoreProperties = java.util.Properties()\n"
        "    val keystorePropertiesFile = rootProject.file(\"key.properties\")\n"
        "    if (keystorePropertiesFile.exists()) {\n"
        "        keystoreProperties.load(java.io.FileInputStream(keystorePropertiesFile))\n"
        "    }\n"
    )
    signing_block = (
        "\n"
        "    signingConfigs {\n"
        "        create(\"release\") {\n"
        "            keyAlias = keystoreProperties[\"keyAlias\"] as String\n"
        "            keyPassword = keystoreProperties[\"keyPassword\"] as String\n"
        "            storeFile = file(keystoreProperties[\"storeFile\"] as String)\n"
        "            storePassword = keystoreProperties[\"storePassword\"] as String\n"
        "        }\n"
        "    }\n"
    )
    debug_pattern = r'signingConfig\s*=\s*signingConfigs\.getByName\("debug"\)'
    debug_replacement = 'signingConfig = signingConfigs.getByName("release")'
else:
    props_block = (
        "\n"
        "    def keystoreProperties = new Properties()\n"
        "    def keystorePropertiesFile = rootProject.file('key.properties')\n"
        "    if (keystorePropertiesFile.exists()) {\n"
        "        keystoreProperties.load(new FileInputStream(keystorePropertiesFile))\n"
        "    }\n"
    )
    signing_block = (
        "\n"
        "    signingConfigs {\n"
        "        release {\n"
        "            keyAlias keystoreProperties['keyAlias']\n"
        "            keyPassword keystoreProperties['keyPassword']\n"
        "            storeFile keystoreProperties['storeFile'] ? file(keystoreProperties['storeFile']) : null\n"
        "            storePassword keystoreProperties['storePassword']\n"
        "        }\n"
        "    }\n"
    )
    debug_pattern = r'signingConfig\s+signingConfigs\.debug'
    debug_replacement = 'signingConfig signingConfigs.release'

text, n = re.subn(r'^android \{', 'android {' + props_block, text, count=1, flags=re.MULTILINE)
if n != 1:
    sys.exit(f"ERROR: could not find 'android {{' block start in {gradle_file}")

text, n = re.subn(
    r'^(\s*)buildTypes \{',
    lambda m: signing_block + m.group(1) + 'buildTypes {',
    text,
    count=1,
    flags=re.MULTILINE,
)
if n != 1:
    sys.exit(f"ERROR: could not find 'buildTypes {{' block in {gradle_file}")

text, n = re.subn(debug_pattern, debug_replacement, text)
if n < 1:
    sys.exit(f"ERROR: could not find debug signingConfig reference to replace in {gradle_file}")

gradle_file.write_text(text)
print(f"Patched {gradle_file} for release signing ({'kts' if is_kts else 'groovy'} DSL, {n} debug-signingConfig reference(s) replaced)")
