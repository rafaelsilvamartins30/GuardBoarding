package com.guardboarding.demo.controller;

import com.guardboarding.demo.dto.CreateMemberRequest;
import com.guardboarding.demo.dto.MemberResponse;
import com.guardboarding.demo.service.MemberService;
import jakarta.validation.Valid;
import java.net.URI;
import java.util.List;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/members")
public class MemberController {

  private final MemberService memberService;

  public MemberController(MemberService memberService) {
    this.memberService = memberService;
  }

  @PostMapping
  public ResponseEntity<MemberResponse> createMember(
      @Valid @RequestBody CreateMemberRequest request) {
    MemberResponse created = memberService.createMember(request);
    return ResponseEntity.created(URI.create("/api/members/" + created.getId())).body(created);
  }

  @GetMapping("/{id}")
  public ResponseEntity<MemberResponse> getMember(@PathVariable String id) {
    return memberService
        .findMemberById(id)
        .map(ResponseEntity::ok)
        .orElseGet(() -> ResponseEntity.notFound().build());
  }

  @GetMapping
  public ResponseEntity<List<MemberResponse>> listMembers() {
    return ResponseEntity.ok(memberService.listAllMembers());
  }
}
