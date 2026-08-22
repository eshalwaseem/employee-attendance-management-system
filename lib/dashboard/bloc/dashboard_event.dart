abstract class DashboardEvent {
  const DashboardEvent();
}

class DashboardStarted extends DashboardEvent {
  const DashboardStarted();
}

class CheckInRequested extends DashboardEvent {
  const CheckInRequested();
}

