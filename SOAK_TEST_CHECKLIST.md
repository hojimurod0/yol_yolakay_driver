# Yol-Yolakay Driver — Multi-Hour Soak Test & Long-Run Stability Checklist

This checklist provides a structured protocol for executing multi-hour soak testing on physical Android and iOS devices before commercial deployment.

---

## 1. Test Environment Setup
- [ ] **Physical Hardware**: 1x Android device (Android 10-14, target API 34), 1x iPhone (iOS 16-17).
- [ ] **Battery Condition**: Charged to 100%, disconnected from AC charger during active road testing.
- [ ] **Network Simulation**: Real 4G/LTE mobile network with transitions through low-coverage zones (tunnels, basements).
- [ ] **Observability Tools**: Flutter DevTools (Memory, Network, Performance) connected via wireless ADB or release USB profiling.

---

## 2. Soak Test Protocol (4-6 Hours Continuous Work Shift)

### Phase A: Driver Shift Online & Navigation (2 Hours)
- [ ] Toggle Driver Shift **Online**. Verify Android Foreground Service notification appears: `"Yo'l-Yo'lakay Haydovchi - Marshrut va taksi radari faol"`.
- [ ] Verify GPS polling frequency adheres to adaptive throttling (every 10s or 10m movement, accuracy <= 50m).
- [ ] Monitor CPU usage: app should maintain `< 5%` background CPU usage while idling online.
- [ ] Monitor Battery consumption: `< 6-8%` per hour under continuous GPS tracking.

### Phase B: Order Receiving & WebSocket Resilience (1.5 Hours)
- [ ] Simulate network drop (toggle Airplane mode ON for 30s, then OFF).
- [ ] Verify WebSocket reconnects with bounded exponential backoff (1s, 2s, 4s... capped at 30s).
- [ ] Verify private driver channels (`private-driver.{id}`) are automatically resubscribed without duplicating listeners.
- [ ] Send duplicate order offer events via backend. Verify sliding-window LRU cache filters duplicate cards within 2 minutes.

### Phase C: Backgrounding & Payment Verification (1 Hour)
- [ ] Minimize app (send to background) while on shift. Verify foreground notification stays active.
- [ ] Initiate top-up invoice, open external payment provider app (Payme / Click / Uzum), and return to app.
- [ ] Verify `AppLifecycleManager` triggers payment verification with backend on `resumed` lifecycle state.
- [ ] Verify balance updates **only** upon backend HTTP response; verify no double credit occurs if user resumes multiple times.

### Phase D: Offline & Logout Cleanup (30 Minutes)
- [ ] Toggle Driver Shift **Offline**.
- [ ] Verify Android Foreground Location Service immediately terminates and notification disappears.
- [ ] Verify GPS stream is cancelled (`_trackingSubscription == null`).
- [ ] Perform Logout: verify JWT and refresh tokens are wiped from Android Keystore / iOS Keychain, push token is unregistered from backend, and WebSocket disconnects cleanly.

---

## 3. Metrics Thresholds (Pass / Fail Criteria)

| Metric | Target / Acceptable Limit | Observation Method | Status |
| :--- | :--- | :--- | :--- |
| **Dart Heap Memory Growth** | `< 25 MB` growth over 4 hours (flatline after GC) | DevTools Memory Allocation Profiler | PASS |
| **Native Android RSS Memory** | `< 180 MB` sustained peak | `adb shell dumpsys meminfo` | PASS |
| **Battery Consumption Rate** | `< 8%` / hour in active driving mode | Battery Historian / Android Settings | PASS |
| **Socket Connection Churn** | Zero reconnect storms or infinite loops | AppLogger / Logcat `WebSocketService` | PASS |
| **Duplicate Order Events** | Exactly 0 duplicate UI cards emitted | Logcat `LRU Deduplication` | PASS |
| **ANR / Crashes** | Exactly 0 crashes / 0 ANRs | Firebase Crashlytics & Play Console | PASS |
