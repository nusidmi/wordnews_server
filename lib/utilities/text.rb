require 'set'

module Utilities::Text

  # http://www.ling.upenn.edu/courses/Fall_2003/ling001/penn_treebank_pos.html
  # adj, noun, adv, verb
  @@selected_set = Set.new(['JJ', 'NN', 'RB', 'VB'])
  
  def self.is_proper_to_learn(word, tag)
    return @@selected_set.include? tag
  end
  
  
end