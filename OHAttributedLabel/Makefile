
default:
	xcodebuild -target OHAttributedLabel -configuration Release -sdk iphonesimulator build
	xcodebuild -target OHAttributedLabel -configuration Release -sdk iphoneos build	
	./scripts/combine-libs.sh build Release

clean:
	-rm -rf build/*



