defmodule Spellbot.WordListTest do
  use ExUnit.Case, async: true

  setup do
    {:ok, word_list} = Spellbot.WordList.start_link
    {:ok, word_list: word_list}
  end

  test "checks words", %{word_list: word_list} do
    assert Spellbot.WordList.spelled_good?(word_list, "hello") == true
  end

  test "counts words", %{word_list: word_list} do
    assert is_number(Spellbot.WordList.get_count(word_list, "hello"))
  end

  test "updates words", %{word_list: word_list} do
    Spellbot.WordList.set_word(word_list, "hello", 5)
    assert Spellbot.WordList.get_count(word_list, "hello") == 5
  end
end
