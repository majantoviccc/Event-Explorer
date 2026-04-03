alias EventExplorer.Repo
alias EventExplorer.Events.Event
alias EventExplorer.Uploaders.Cloudinary

events = Repo.all(Event)

Enum.each(events, fn event ->
  if event.image do
    public_id = Cloudinary.extract_public_id(event.image)

    event
    |> Ecto.Changeset.change(public_id: public_id)
    |> Repo.update!()
  end
end)
