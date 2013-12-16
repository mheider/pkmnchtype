#!/usr/bin/ruby
# encoding: UTF-8

require 'rubygems'
require 'nokogiri'
require 'open-uri'
require 'terminal-table'

$page
$pokemon
$types_table

def load_page
  begin
    $page = Nokogiri::HTML(open("http://www.pokewiki.de/#{$pokemon}"))
  rescue
    p "could not find PoKeMoN :("
    exit
  end
end

def analyze_table
  div_table = $page.css("div[class=effizienz-tabelle]")
  effectiveness = div_table.css("table").css("tr")[2].css("td")
  
  $types_table = Array.new(6)
  
  effectiveness.to_enum.with_index.each do |effect, index|
    unless $types_table[index]
      $types_table[index] = Array.new
    end
    
    effect.css("span").each do |type_span|
      $types_table[index].push(type_span.text)
    end
  end

end

def build_term_table
  title = "Effektivitäten für #{$pokemon}"
  
  max_len = 0
  $types_table.each do |type|
    if type.count > max_len
      max_len = type.count
    end
  end
  
  rows = []
  max_len.times do |i|
    row = []
    $types_table.each do |effect|
      if effect[i]
        row << effect[i]
      else
        row << " "
      end
    end
    rows << row
  end
  
  
  table = Terminal::Table.new :title => title, 
                              :rows => rows,
                              :headings => ['*0', '*0.25', '*0,5', '*1', '*2', '*4']
  
  table.style = {padding_left: 3, padding_right: 3,  border_x: "=", border_i: "+"}
  
  p table
  
end

def print_source
  print "#-- Quelle: http://www.pokewiki.de/#{$pokemon}\n\n"
end

def main
  load_page
  
  analyze_table
  
  build_term_table
  
  print_source
end

if __FILE__ == $0
  $pokemon = ARGV[0]
  
  unless $pokemon
    print "please insert a pokemon-name\n"
    print "usage: ruby #{$0} 'pokemon-name'\n"
    exit
  end
  
  main

end
