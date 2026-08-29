package com.guardboarding.demo.model;

import java.time.LocalDate;
import java.util.Objects;

public class Member {

  private final String id;
  private final String name;
  private final String email;
  private final String role;
  private final OnboardingStatus status;
  private final LocalDate joinedAt;

  public Member(
      String id,
      String name,
      String email,
      String role,
      OnboardingStatus status,
      LocalDate joinedAt) {
    this.id = Objects.requireNonNull(id, "id must not be null");
    this.name = Objects.requireNonNull(name, "name must not be null");
    this.email = Objects.requireNonNull(email, "email must not be null");
    this.role = Objects.requireNonNull(role, "role must not be null");
    this.status = Objects.requireNonNull(status, "status must not be null");
    this.joinedAt = Objects.requireNonNull(joinedAt, "joinedAt must not be null");
  }

  public String getId() {
    return id;
  }

  public String getName() {
    return name;
  }

  public String getEmail() {
    return email;
  }

  public String getRole() {
    return role;
  }

  public OnboardingStatus getStatus() {
    return status;
  }

  public LocalDate getJoinedAt() {
    return joinedAt;
  }
}
