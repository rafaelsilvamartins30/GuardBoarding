package com.guardboarding.demo.service;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertNotNull;
import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.junit.jupiter.api.Assertions.assertTrue;

import com.guardboarding.demo.dto.CreateMemberRequest;
import com.guardboarding.demo.dto.MemberResponse;
import com.guardboarding.demo.model.OnboardingStatus;
import com.guardboarding.demo.repository.InMemoryMemberRepository;
import java.util.List;
import java.util.Optional;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;

class MemberServiceTest {

  private MemberService memberService;

  @BeforeEach
  void setUp() {
    memberService = new MemberService(new InMemoryMemberRepository());
  }

  @Test
  void shouldCreateMemberSuccessfully() {
    CreateMemberRequest request =
        new CreateMemberRequest("Rafael Silva", "rafael@example.com", "Software Engineer");

    MemberResponse response = memberService.createMember(request);

    assertNotNull(response.getId());
    assertEquals("Rafael Silva", response.getName());
    assertEquals("rafael@example.com", response.getEmail());
    assertEquals(OnboardingStatus.PENDING, response.getStatus());
  }

  @Test
  void shouldNotAllowDuplicateEmail() {
    CreateMemberRequest request1 =
        new CreateMemberRequest("Rafael Silva", "duplicate@example.com", "Dev");
    CreateMemberRequest request2 =
        new CreateMemberRequest("Outro Dev", "duplicate@example.com", "Dev");

    memberService.createMember(request1);

    assertThrows(IllegalArgumentException.class, () -> memberService.createMember(request2));
  }

  @Test
  void shouldFindMemberById() {
    CreateMemberRequest request =
        new CreateMemberRequest("Ana Lima", "ana@example.com", "Product Manager");
    MemberResponse created = memberService.createMember(request);

    Optional<MemberResponse> found = memberService.findMemberById(created.getId());

    assertTrue(found.isPresent());
    assertEquals("Ana Lima", found.get().getName());
  }

  @Test
  void shouldListAllMembers() {
    memberService.createMember(new CreateMemberRequest("Dev 1", "dev1@example.com", "Dev"));
    memberService.createMember(new CreateMemberRequest("Dev 2", "dev2@example.com", "Dev"));

    List<MemberResponse> members = memberService.listAllMembers();

    assertEquals(2, members.size());
  }
}
