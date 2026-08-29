package com.guardboarding.demo.repository;

import com.guardboarding.demo.model.Member;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.concurrent.ConcurrentHashMap;
import org.springframework.stereotype.Repository;

@Repository
public class InMemoryMemberRepository implements MemberRepository {

  private final Map<String, Member> storage = new ConcurrentHashMap<>();

  @Override
  public Member save(Member member) {
    storage.put(member.getId(), member);
    return member;
  }

  @Override
  public Optional<Member> findById(String id) {
    return Optional.ofNullable(storage.get(id));
  }

  @Override
  public Optional<Member> findByEmail(String email) {
    return storage.values().stream()
        .filter(member -> member.getEmail().equalsIgnoreCase(email))
        .findFirst();
  }

  @Override
  public List<Member> findAll() {
    return Collections.unmodifiableList(new ArrayList<>(storage.values()));
  }
}
