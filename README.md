# GitIgnore 캐시 삭제
git rm -r --cached .

# Model 생성
flutter pub run build_runner build

# 안드로이드 인증키 생성
keytool -genkey -v -keystore android/app/${ALIAS_NAME}.jks -keyalg RSA -keysize 2048 -validity 10000 -alias ${ALIAS_NAME} -storetype JKS

# 안드로이드 인증키 출력
keytool -list -v -alias ${ALIAS_NAME} -keystore android/app/${ALIAS_NAME}.jks

# 디버그 키해시
keytool -exportcert -alias androiddebugkey -keystore ~/.android/debug.keystore -storepass android -keypass android | openssl sha1 -binary | openssl base64

# 릴리즈 키해시
keytool -exportcert -alias ${ALIAS_NAME} -keystore ${KEY_PATH} | openssl sha1 -binary | openssl base64  (릴리즈 키 해시)

# 업로드 캐해시
echo ${SHA1 인증 지문} | xxd -r -p | openssl base64

# 정식 버전 앱 빌드
- appbundle
  flutter clean && flutter pub get && cd ios && pod install && cd .. && flutter build appbundle --flavor prod -t lib/prod.dart
- apk
  flutter clean && flutter pub get && cd ios && pod install && cd .. && flutter build apk --flavor prod -t lib/prod.dart

# 개발 버전 앱 빌드
- appbundle
  flutter clean && flutter pub get && cd ios && pod install && cd .. && flutter build appbundle --flavor dev -t lib/dev.dart
- apk
  flutter clean && flutter pub get && cd ios && pod install && cd .. && flutter build apk --flavor dev -t lib/dev.dart