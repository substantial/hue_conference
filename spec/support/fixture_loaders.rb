
def google_events_response_hash
  JSON.parse(IO.read(File.join(File.dirname(__FILE__), "fixtures", "google_events_response.json")) )
end

