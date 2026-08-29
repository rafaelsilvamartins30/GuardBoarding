package com.guardboarding.demo.service;

import com.guardboarding.demo.dto.CreateMemberRequest;
import com.guardboarding.demo.dto.MemberResponse;
import com.guardboarding.demo.model.Member;
import com.guardboarding.demo.model.OnboardingStatus;
import com.guardboarding.demo.repository.MemberRepository;
import java.time.LocalDate;
import java.util.List;
import java.util.Optional;
import java.util.UUID;
import org.springframework.stereotype.Service;

@Service
public class MemberService {

  private final MemberRepository memberRepository;

  public MemberService(MemberRepository memberRepository) {
    this.memberRepository = memberRepository;
  }

  public MemberResponse createMember(CreateMemberRequest request) {
    if (memberRepository.findByEmail(request.getEmail()).isPresent()) {
      throw new IllegalArgumentException("Member with email already exists: " + request.getEmail());
    }

    Member member =
        new Member(
            UUID.randomUUID().toString(),
            request.getName(),
            request.getEmail(),
            request.getRole(),
            OnboardingStatus.PENDING,
            LocalDate.now());

    Member saved = memberRepository.save(member);
    return MemberResponse.fromDomain(saved);
  }

  public Optional<MemberResponse> findMemberById(String id) {
    return memberRepository.findById(id).map(MemberResponse::fromDomain);
  }

  public List<MemberResponse> listAllMembers() {
    return memberRepository.findAll().stream().map(MemberResponse::fromDomain).toList();
  }
}
