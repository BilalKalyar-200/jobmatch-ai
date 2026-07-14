"""Tests for search history deletion."""

from uuid import uuid4

from app.repositories.search_history_repository import SearchHistoryRepository


def test_delete_search_history_entry(client, db, auth_headers):
    user_a, headers_a = auth_headers(f"search_delete_a_{uuid4()}@example.com")
    _user_b, headers_b = auth_headers(f"search_delete_b_{uuid4()}@example.com")

    history_repo = SearchHistoryRepository(db)
    entry = history_repo.create(
        user_id=user_a.id,
        niche="Python developer",
        country="pk",
        cities=["Karachi", "Lahore"],
    )

    delete_response = client.delete(
        f"/api/v1/saved/searches/{entry.id}",
        headers=headers_a,
    )
    assert delete_response.status_code == 204
    assert delete_response.content == b""

    list_response = client.get("/api/v1/saved/searches", headers=headers_a)
    assert list_response.status_code == 200
    search_ids = [item["id"] for item in list_response.json()["searches"]]
    assert str(entry.id) not in search_ids

    other_user_entry = history_repo.create(
        user_id=user_a.id,
        niche="Data scientist",
        country="us",
        cities=["Austin"],
    )

    forbidden_response = client.delete(
        f"/api/v1/saved/searches/{other_user_entry.id}",
        headers=headers_b,
    )
    assert forbidden_response.status_code == 404
    assert forbidden_response.json()["error"] == "Search history entry not found."

    owner_list_response = client.get("/api/v1/saved/searches", headers=headers_a)
    owner_search_ids = [item["id"] for item in owner_list_response.json()["searches"]]
    assert str(other_user_entry.id) in owner_search_ids
