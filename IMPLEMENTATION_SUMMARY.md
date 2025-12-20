# Presentation Generation WebView Integration - Implementation Summary

## Overview
This document summarizes the implementation of the WebView-based presentation generation flow, which replaces the previous mobile API approach with an embedded Vue.js web application.

## Date
December 18, 2025

## Branch
`feat/datn-325`

---

## Key Changes

### 1. Configuration Management

#### `.env` File
Updated to include the presentation base URL:
```env
SERVER_BASEURL=
PRESENTATION_BASEURL=https://datn-fe-q3anuqwnd-datn-fe.vercel.app
```

#### `lib/core/config/config.dart`
Added dynamic loading of presentation URL from environment variables:
```dart
import 'package:flutter_dotenv/flutter_dotenv.dart';

static String get presentationBaseUrl =>
    dotenv.env['PRESENTATION_BASEURL'] ??
    'https://datn-fe-presentation.vercel.app';
```

---

### 2. Reusable Authenticated WebView Widget

#### `lib/shared/widgets/authenticated_webview.dart`
Created a generic, reusable WebView widget that:
- Automatically reads access and refresh tokens from secure storage
- Sets HTTP-only, secure cookies for authentication
- Configures WebView with optimal settings (JS enabled, DOM storage, proper user agent)
- Only renders after cookies are successfully set
- Designed to be reusable for Presentation, Mindmap, and other web-based features

**Key Features:**
- Cookie-based authentication (HTTP-only, Secure)
- Platform-specific user agents (iOS/Android)
- Proper error handling
- Loading state management

---

### 3. Presentation Generation Request Schema Update

#### `lib/features/generate/data/dto/presentation_generate_request_dto.dart`
Updated the DTO to match the backend API schema:
```dart
@JsonSerializable()
class PresentationGenerateRequest {
  final String model;
  final String provider;
  final String language;
  final int slideCount;
  final String outline;
  final Map<String, dynamic>? presentation;  // Contains theme + viewport
  final Map<String, dynamic>? others;        // NEW: contentLength + imageModel
}
```

**New `others` field structure:**
```json
{
  "contentLength": "",
  "imageModel": {
    "name": "google/gemini-2.5-flash-image-preview",
    "provider": "openRouter"
  }
}
```

---

### 4. Enhanced Form Controller

#### `lib/features/generate/states/presentations/presentation_form_controller.dart`
Updated `toPresentationRequest()` method to:
- Accept `WidgetRef` parameter to access theme provider
- Build complete `presentation.theme` object from API (full theme data with colors, fonts, shadows, etc.)
- Construct `others` field with contentLength and imageModel configuration
- Properly handle theme selection from the API

**Before:**
```dart
PresentationGenerateRequest toPresentationRequest()
```

**After:**
```dart
PresentationGenerateRequest toPresentationRequest(WidgetRef ref)
```

---

### 5. Presentation Generation WebView Page

#### `lib/features/generate/ui/pages/presentation_generation_webview_page.dart`
Created a new page that embeds the Vue app's `/generation` route with:

**Communication Handlers:**
1. **`generationViewReady`**: Triggered when Vue app is ready to receive data
2. **`generationStarted`**: Receives generation start confirmation with success/error status
3. **`generationCompleted`**: Receives completion status and handles navigation

**Data Flow:**
```
Flutter sends → window.setGenerationData(presentation, generationRequest)
Vue app receives → Processes generation → Sends callbacks
Flutter handles callbacks → Shows states → Navigates on completion
```

**Features:**
- Authenticated WebView with automatic cookie setup
- Loading states with user-friendly messages
- Error handling and display
- Cancellation confirmation dialog
- Automatic navigation to presentation detail on success
- Console logging for debugging

---

### 6. Updated Router Configuration

#### `lib/core/router/router.dart`
Added new route for the generation webview:
```dart
AutoRoute(
  page: PresentationGenerationWebViewRoute.page,
  path: '/presentation/generate/view',
),
```

---

### 7. Generate Button Flow Update

#### `lib/features/generate/ui/pages/generate_page/presentation_generate_page.dart`
**Old Flow:**
```dart
void _handleGenerate() {
  final outlineData = formController.toOutlineData();
  ref.read(presentationGenerateControllerProvider.notifier)
     .generateOutline(outlineData);
}
```

**New Flow:**
```dart
void _handleGenerate() {
  _topicFocusNode.unfocus();
  // Navigate directly to the generation webview
  context.router.push(const PresentationGenerationWebViewRoute());
}
```

**Removed:**
- Outline generation API call
- Generation completion listener
- State management for outline response

---

## Technical Architecture

### Authentication Flow
```
1. User opens generation webview
2. AuthenticatedWebView reads tokens from SecureStorage
3. CookieManager sets HTTP-only cookies (access_token, refresh_token)
4. WebView loads Vue app with authenticated session
5. Vue app makes authenticated API calls using cookies
```

### Data Payload Structure
```json
{
  "presentationId": "temp_1734518400000",
  "outline": "markdown outline here",
  "model": {
    "name": "gpt-4o",
    "provider": "openai"
  },
  "slideCount": 5,
  "language": "English",
  "presentation": {
    "theme": {
      "id": "creative",
      "name": "Creative",
      "backgroundColor": {...},
      "themeColors": [...],
      "fontName": "Poppins",
      "fontColor": "#581c87",
      // ... full theme object
    },
    "viewport": {
      "width": 1000,
      "height": 562.5
    }
  },
  "others": {
    "contentLength": "",
    "imageModel": {
      "name": "google/gemini-2.5-flash-image-preview",
      "provider": "openRouter"
    }
  }
}
```

---

## Files Created

1. `lib/shared/widgets/authenticated_webview.dart` - Reusable authenticated WebView widget
2. `lib/features/generate/ui/pages/presentation_generation_webview_page.dart` - Generation webview page

---

## Files Modified

1. `.env` - Added PRESENTATION_BASEURL
2. `lib/core/config/config.dart` - Added presentationBaseUrl getter
3. `lib/features/generate/data/dto/presentation_generate_request_dto.dart` - Added `others` field
4. `lib/features/generate/states/controller_provider.dart` - Added theme provider import
5. `lib/features/generate/states/presentations/presentation_form_controller.dart` - Updated `toPresentationRequest()`
6. `lib/features/generate/ui/pages/generate_page/presentation_customization_page.dart` - Pass `ref` to `toPresentationRequest()`
7. `lib/core/router/router.dart` - Added new route
8. `lib/features/generate/ui/pages/generate_page/presentation_generate_page.dart` - Updated generate handler
9. `lib/features/projects/ui/widgets/presentation/presentation_detail.dart` - Uses AuthenticatedWebView

---

## Benefits of This Approach

### 1. **Code Reusability**
- `AuthenticatedWebView` can be reused for Mindmap and other web-based features
- Consistent authentication pattern across all embedded web apps

### 2. **Separation of Concerns**
- Generation logic lives in the Vue app (single source of truth)
- Mobile app focuses on UI/UX and data passing
- Easier to maintain and update generation features

### 3. **Real-time Updates**
- Users see slides being generated in real-time
- Better user experience with streaming progress

### 4. **Simplified Mobile Code**
- No need to implement complex generation logic in Flutter
- Reduced API surface and state management
- Fewer dependencies and potential bugs

### 5. **Consistency**
- Same generation experience across web and mobile
- Easier to ensure feature parity

---

## Future Enhancements

### Mindmap Integration
The same pattern can be applied for Mindmap generation:
1. Create `MindmapGenerationWebViewPage`
2. Use the same `AuthenticatedWebView` widget
3. Point to `/mindmap/generation` route
4. Implement similar communication handlers

### Error Recovery
- Implement retry mechanism for failed generations
- Add ability to save draft and resume later
- Better error messaging with actionable suggestions

### Offline Support
- Cache generated presentations locally
- Allow viewing cached presentations without internet
- Sync when connection is restored

---

## Testing Checklist

- [x] Authentication cookies are set correctly
- [x] WebView loads the Vue app successfully
- [x] Communication handlers receive callbacks
- [x] Generation data is sent with correct schema
- [x] Loading states display properly
- [x] Error states handle failures gracefully
- [x] Navigation works on successful completion
- [x] Cancellation dialog prevents accidental exits
- [ ] Test on iOS devices
- [ ] Test on Android devices
- [ ] Test with different network conditions
- [ ] Test theme selection integration
- [ ] End-to-end generation flow

---

## Known Issues / Limitations

1. **Temporary Presentation ID**: Currently uses timestamp-based temp ID, backend should return the real ID
2. **Network Dependency**: Requires internet connection for generation (no offline mode)
3. **Limited Error Recovery**: User must restart if generation fails
4. **No Progress Persistence**: Closing the webview loses progress

---

## References

- [FLUTTER_INTEGRATION.md](./FLUTTER_INTEGRATION.md) - Vue app integration guide
- [WebView Package](https://pub.dev/packages/flutter_inappwebview) - InAppWebView documentation
- Backend API: `https://api.huy-devops.site/api`
- Presentation Frontend: `https://datn-fe-q3anuqwnd-datn-fe.vercel.app`

---

## Conclusion

This implementation successfully replaces the mobile API-based generation flow with an embedded WebView solution, providing a better user experience with real-time generation feedback while maintaining code simplicity and reusability. The architecture is extensible and can be easily adapted for other features like Mindmap generation.
