package com.guardboarding.demo.repository;

import com.guardboarding.demo.model.Member;
import java.util.List;
import java.util.Optional;

public interface MemberRepository {

  Member save(Member member);

  Optional<Member> findById(String id);

  Optional<Member> findByEmail(String email);

  List<Member> findAll();
}
