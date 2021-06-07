require "tilt/erubis"
require "sinatra"
require "sinatra/reloader" if development?

before do
  @toc = File.readlines("data/toc.txt")
end

helpers do

  def slugify(text)
    text.downcase.gsub(/\s+/, "-").gsub(/[^\w]/, "")
  end

  def in_paragraphs(text)
    text.split("\n\n").each_with_index.map do |line, index|
      "<p id=paragraph#{index}>#{line}</p>"
    end.join
  end

  def each_chapter
    @toc.each_with_index do |name, idx|
    number = idx + 1
    contents = File.read("data/chp#{number}.txt")
     yield number, name, contents
    end
  end

  def chapters_matching(query)
    results = []  

    return results unless query 

    each_chapter do |number, name, contents|
      matches = {}
      contents.split("\n\n").each_with_index do |paragraph, index|
        matches[index] = paragraph if paragraph.include?(query)
      end
      results << {number: number, name: name, paragraphs: matches} if matches.any?
    end 

    results
  end

  def highlight(text, term)
    text.gsub(term, %(<strong><em>#{term}</em></strong>))
  end


end


get "/" do
  @title = "Testing code for The Adventures of Sherlock Holmes in the YEAR 2000!"
  erb :home#, layout :layout
end

get "/chapters/:number" do

  number = params[:number].to_i
  chapter_name = @toc[number - 1]

  redirect "/" unless (1..@toc.size).cover?(number)

  @title = "Chapter #{number}: #{chapter_name}"

  @chapter = File.read("data/chp#{number}.txt")

  erb :chapter
end

get "/show/:name" do
  params[:name]
end

not_found do
  redirect "/"
end

get "/search" do
  @results = chapters_matching(params[:query])
  erb :search
end

