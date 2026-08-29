package com.guardboarding.demo.dto;

import com.guardboarding.demo.model.Member;
import com.guardboarding.demo.model.OnboardingStatus;
import java.time.LocalDate;

public class MemberResponse {

  private final String id;
  private final String name;
  private final String email;
  private final String role;
  private final OnboardingStatus status;
  private final LocalDate joinedAt;

  public MemberResponse(
      String id,
      String name,
      String email,
      String role,
      OnboardingStatus status,
      LocalDate joinedAt) {
    this.id = id;
    this.name = name;
    this.email = email;
    this.role = role;
    this.status = status;
    this.joinedAt = joinedAt;
  }

  public static MemberResponse fromDomain(Member member) {
    return new MemberResponse(
        member.getId(),
        member.getName(),
        member.getEmail(),
        member.getRole(),
        member.getStatus(),
        member.getJoinedAt());
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
