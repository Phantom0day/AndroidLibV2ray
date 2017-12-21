pb:
	  go get -u github.com/golang/protobuf/protoc-gen-go
		@echo "pb Start"
		cd configure && make pb
asset:
	mkdir assets
	cd assets;curl https://cdn.rawgit.com/v2ray/v2ray-core/e60de73c704d46d91633035e6b06184f7186a4e0/tools/release/config/geosite.dat > geosite.dat
	cd assets;curl https://cdn.rawgit.com/v2ray/v2ray-core/v3.1/tools/release/config/geoip.dat > geoip.dat

shippedBinary:
	cd shippedBinarys; $(MAKE) shippedBinary

fetchDep:
	-go get -u github.com/xiaokangwang/V2RayConfigureFileUtil
	-cd $(GOPATH)/src/github.com/xiaokangwang/V2RayConfigureFileUtil;$(MAKE) all
	go get -u github.com/xiaokangwang/V2RayConfigureFileUtil
	-go get -u github.com/xiaokangwang/AndroidLibV2ray
	-cd $(GOPATH)/src/github.com/xiaokangwang/libV2RayAuxiliaryURL; $(MAKE) all
	go get -u github.com/xiaokangwang/AndroidLibV2ray

ANDROID_HOME=$(HOME)/android-sdk-linux
export ANDROID_HOME
downloadGoMobile:
	go get golang.org/x/mobile/cmd/gomobile
	sudo apt-get install -qq libstdc++6:i386 lib32z1 expect
	cd ~ ;curl -L https://gist.githubusercontent.com/xiaokangwang/4a0f19476d86213ef6544aa45b3d2808/raw/b5c308b43d231e785b869844b7b341e5c098b84b/ubuntu-cli-install-android-sdk.sh | sudo bash -
	ls ~
	ls ~/android-sdk-linux/
	gomobile init -ndk ~/android-ndk-r15c;gomobile bind -v  -tags json github.com/xiaokangwang/AndroidLibV2ray

buildVGO:
	git clone https://github.com/xiaokangwang/V2RayGO.git
	ln libv2ray.aar V2RayGO/libv2ray/libv2ray.aar
	cd V2RayGO;echo "sdk.dir=$(ANDROID_HOME)" > local.properties
	cd V2RayGO; ./gradlew assembleRelease
	cd V2RayGO/app/build/outputs/apk/release; $(ANDROID_HOME)/build-tools/27.0.1/zipalign -v -p 4 app-release-unsigned.apk app-release-unsigned-aligned.apk
	cd V2RayGO/app/build/outputs/apk/release; keytool -genkey -v -keystore temp-release-key.jks -keyalg RSA -keysize 2048 -validity 365 -alias tempkey -dname "CN=vvv.kkdev.org, OU=VV, O=VVV, L=VVVVV, S=VV, C=VV" -storepass password -keypass password -noprompt
	cd V2RayGO/app/build/outputs/apk/release; $(ANDROID_HOME)/build-tools/27.0.1/apksigner sign --ks temp-release-key.jks  --ks-pass pass:password --key-pass pass:password --out app-release.apk app-release-unsigned-aligned.apk

BuildMobile:
	@echo Stub

all: asset pb shippedBinary fetchDep
	@echo DONE
