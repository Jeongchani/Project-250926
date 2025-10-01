
# Heart App Overlay (No-DB Prototype)

이 압축은 **데이터베이스 없이**도 기본 흐름을 구현하는 Flutter 오버레이입니다.

## 포함 기능
- 닉네임/온보딩 (로컬 저장, SharedPreferences)
- 커플 연결: 코드/커스텀 딥링크(heartapp://pair?code=...&name=...) 기반 (uni_links)
- 메인 하트 화면: 메시지 입력 → "보냈다고 가정" (백엔드 연결 전까지 로컬 피드백)
- 설정: 하트 색상(팔레트/HEX, flutter_colorpicker), 저장 메시지, 프리미엄(광고/결제 자리만)

## 적용 방법
1) 이 폴더의 `lib/`를 프로젝트의 `lib/`에 **덮어쓰기**(혹은 수동 병합) 하세요.

2) `pubspec.yaml`의 dependencies에 **아래 항목을 추가**하고 `flutter pub get`:
```
dependencies:
  provider: ^6.0.5
  shared_preferences: ^2.3.2
  flutter_colorpicker: ^1.0.3
  share_plus: ^10.0.2
  uni_links: ^0.5.1
  uuid: ^4.5.1
```

3) (Android) **딥링크 인텐트 필터** 추가 – `android/app/src/main/AndroidManifest.xml`의 `<activity>`(MainActivity) 안에 다음을 넣으세요:
```xml
<intent-filter android:autoVerify="false">
    <action android:name="android.intent.action.VIEW" />
    <category android:name="android.intent.category.DEFAULT" />
    <category android:name="android.intent.category.BROWSABLE" />
    <data android:scheme="heartapp" android:host="pair" />
</intent-filter>
```

4) 빌드 & 실행
```
flutter clean
flutter pub get
flutter run
```

## 사용법 요약
- 상단 우측 "링크" → 내 코드 확인, **공유 버튼**으로 heartapp:// 링크 내보내기
- 상대가 링크를 눌러 앱으로 열면 자동 연결됨(상대 기기에 앱 설치 필요)
- 메인에서 하트를 누르면 입력칸 문구(비면 설정의 저장된 메시지)로 전송된 것으로 간주하여 스낵바 표시

## 이후 확장
- 실제 전송/푸시: 백엔드(Supabase/PocketBase 등) + FCM
- 프리미엄: 광고 SDK(AdMob)/인앱결제
- 쿨다운/상대가 누르기 전까지 잠금: 서버 상태 필드 필요
- 홈 위젯: Android AppWidget/Glance 또는 관련 플러그인
