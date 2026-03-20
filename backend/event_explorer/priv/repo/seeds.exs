alias EventExplorer.Repo
alias EventExplorer.Cities.City
alias EventExplorer.Categories.Category
alias EventExplorer.Venues.Venue
alias EventExplorer.Events.Event

# ========================

# CITIES

# ========================

cities = [
"Belgrade","Berlin","Tallinn","London","Amsterdam","Prague",
"Milan","Cannes","Ibiza","Paris","Barcelona","Copenhagen",
"Zurich","Lisbon","Rome"
]

cities
|> Enum.each(fn name ->
%City{}
|> City.changeset(%{name: name})
|> Repo.insert!()
end)

# ========================

# CATEGORIES

# ========================

categories = [
"Technology","Business","Art","Film",
"Music","Wellness","Lifestyle","Food"
]

categories
|> Enum.each(fn name ->
%Category{}
|> Category.changeset(%{name: name})
|> Repo.insert!()
end)

# ========================

# VENUES

# ========================

cities_map =
Repo.all(City)
|> Map.new(&{&1.name, &1.id})

venues = [
{"Tech Innovation Hub","Belgrade"},
{"Innovation Center","Berlin"},
{"Security Tech Arena","Tallinn"},
{"Startup Hub","London"},
{"Dev Arena","Amsterdam"},
{"Code Club","Prague"},
{"Art Studio","Milan"},
{"Cinema Center","Cannes"},
{"Ocean Stage","Ibiza"},
{"Blue Note Club","Paris"},
{"Beach Park","Barcelona"},
{"Green Innovation Center","Copenhagen"},
{"Finance Tech Center","Zurich"},
{"Marketing Lab","Lisbon"},
{"Central Square","Rome"}
]

venues
|> Enum.each(fn {name, city} ->
%Venue{}
|> Venue.changeset(%{
name: name,
city_id: cities_map[city]
})
|> Repo.insert!()
end)

# ========================

# EVENTS

# ========================

venues_map =
Repo.all(Venue)
|> Map.new(&{&1.name, &1.id})

categories_map =
Repo.all(Category)
|> Map.new(&{&1.name, &1.id})

events = [
{"React Global Summit","Technology","Tech Innovation Hub","https://res.cloudinary.com/datqqcleg/image/upload/v1773918181/react-summit_e7epcd.png"},
{"AI Future Conference","Technology","Innovation Center","https://res.cloudinary.com/datqqcleg/image/upload/v1773918214/ai-conference_ibb54q.png"},
{"Cybersecurity Defense Summit","Technology","Security Tech Arena","https://res.cloudinary.com/datqqcleg/image/upload/v1773918212/cybersecurity-summit_pnwjml.png"},
{"Startup Pitch Night","Business","Startup Hub","https://res.cloudinary.com/datqqcleg/image/upload/v1773918219/startup-pitch_xsvxkn.png"},
{"24h Global Hackathon","Technology","Dev Arena","https://res.cloudinary.com/datqqcleg/image/upload/v1773918216/hackaton_g6qgkf.png"},
{"Stand-Up Comedy Night","Business","Code Club","https://res.cloudinary.com/datqqcleg/image/upload/v1773918211/comedy_pppaxb.png"},
{"Digital Photography Masterclass","Art","Art Studio","https://res.cloudinary.com/datqqcleg/image/upload/v1773918217/photography_bbts6y.png"},
{"Film Directors Networking Night","Film","Cinema Center","https://res.cloudinary.com/datqqcleg/image/upload/v1773918214/film-directors_k1huoa.png"},
{"Electronic Music Festival","Music","Ocean Stage","https://res.cloudinary.com/datqqcleg/image/upload/v1773918213/electronic-festival_a2fedq.png"},
{"Jazz & Blues Night","Music","Blue Note Club","https://res.cloudinary.com/datqqcleg/image/upload/v1773918216/jazz-night_q4udwc.png"},
{"Outdoor Yoga Festival","Wellness","Beach Park","https://res.cloudinary.com/datqqcleg/image/upload/v1773918302/yoga-festival_xdbiuq.png"},
{"Luxury Fashion Show","Lifestyle","Green Innovation Center","https://res.cloudinary.com/datqqcleg/image/upload/v1773918213/fashion_s1odfi.png"},
{"Extreme Sports Showcase","Technology","Finance Tech Center","https://res.cloudinary.com/datqqcleg/image/upload/v1773918213/extreme_c4sr7o.png"},
{"Gaming Tournament Arena","Business","Marketing Lab","https://res.cloudinary.com/datqqcleg/image/upload/v1773918222/gaming_oadhqt.png"},
{"International Street Food Festival","Food","Central Square","https://res.cloudinary.com/datqqcleg/image/upload/v1773918220/street-food_r3rtta.png"}
]

events
|> Enum.each(fn {title, category, venue, image} ->
%Event{}
|> Event.changeset(%{
title: title,
date: ~D[2026-05-01],
time: ~T[18:00:00],
price: 20,
image: image,
description: "Sample event description",
featured: true,
venue_id: venues_map[venue],
category_id: categories_map[category]
})
|> Repo.insert!()
end)
