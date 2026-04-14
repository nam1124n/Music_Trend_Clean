alias Backend.Music
alias Backend.Repo

if Repo.aggregate(Backend.Music.Song, :count, :id) == 0 do
  [
    %{
      title: "Blinding Lights",
      artist: "The Weeknd",
      audio_url: "https://cdn.example.com/audio/blinding-lights.mp3",
      image_url: "https://cdn.example.com/images/blinding-lights.jpg",
      semantic_tags: ["synthwave", "night-drive", "pop"],
      search_aliases: ["blinding lights", "the weeknd", "after hours"],
      energy_level: 5
    },
    %{
      title: "Save Your Tears",
      artist: "The Weeknd",
      audio_url: "https://cdn.example.com/audio/save-your-tears.mp3",
      image_url: "https://cdn.example.com/images/save-your-tears.jpg",
      semantic_tags: ["retro-pop", "melancholy", "radio-hit"],
      search_aliases: ["save your tears", "weeknd", "after hours deluxe"],
      energy_level: 4
    },
    %{
      title: "Die For You",
      artist: "The Weeknd",
      audio_url: "https://cdn.example.com/audio/die-for-you.mp3",
      image_url: "https://cdn.example.com/images/die-for-you.jpg",
      semantic_tags: ["r&b", "romantic", "late-night"],
      search_aliases: ["die for you", "starboy", "the weeknd die for you"],
      energy_level: 3
    },
    %{
      title: "Call Out My Name",
      artist: "The Weeknd",
      audio_url: "https://cdn.example.com/audio/call-out-my-name.mp3",
      image_url: "https://cdn.example.com/images/call-out-my-name.jpg",
      semantic_tags: ["sad", "slow-burn", "moody"],
      search_aliases: ["call out my name", "my dear melancholy", "weeknd ballad"],
      energy_level: 2
    }
  ]
  |> Enum.each(fn attrs ->
    {:ok, _song} = Music.create_song(attrs)
  end)
end
