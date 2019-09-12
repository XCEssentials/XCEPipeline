#!/bin/bash

# http://www.grymoire.com/Unix/Sed.html#TOC
sed -i '' -e "s|PRODUCT_BUNDLE_IDENTIFIER = \"XCEPipeline\"|PRODUCT_BUNDLE_IDENTIFIER = com.XCEssentials.Pipeline|g" XCEPipeline.xcodeproj/project.pbxproj
