# 안드로이드 릴리스 서명

Play에 올리는 빌드는 본인 키로 서명해야 한다. 디버그 키로 서명된 것은 거부된다.

**이 키를 잃어버리면 같은 앱을 업데이트할 수 없다.** 앱을 지우고 새 패키지명으로
다시 올리는 수밖에 없고, 기존 사용자는 따라오지 않는다. 백업은 필수다.

## 1. 키 만들기 (한 번만)

```bash
keytool -genkey -v -keystore ~/focuscat-upload.jks \
  -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

비밀번호를 두 번 묻는다(키저장소, 키). 같은 것을 써도 된다.
이름·조직 등은 비워도 되고 아무렇게나 넣어도 된다 — 사용자에게 보이지 않는다.

## 2. android/key.properties 만들기

```properties
storePassword=위에서 정한 비밀번호
keyPassword=위에서 정한 비밀번호
keyAlias=upload
storeFile=/Users/hyukkwon/focuscat-upload.jks
```

이 파일과 `.jks`는 `.gitignore`에 들어 있다. **저장소에 올리지 말 것.**
`build.gradle.kts`는 이 파일이 있으면 릴리스 키로, 없으면 디버그 키로 서명한다.

## 3. 빌드

```bash
flutter build appbundle
```

결과: `build/app/outputs/bundle/release/app-release.aab` — 이걸 Play Console에 올린다.

## 4. 백업

- `~/focuscat-upload.jks` 를 안전한 곳에 복사(외장 드라이브·암호 관리자 등)
- 비밀번호도 함께 보관. 둘 중 하나만 잃어도 업데이트가 불가능하다.

Play App Signing을 쓰면 구글이 배포용 키를 대신 관리해 주지만, 여기서 만드는
업로드 키는 여전히 본인이 지켜야 한다.
