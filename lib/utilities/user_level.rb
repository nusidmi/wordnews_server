module Utilities::UserLevel
  ACTION = {view: 'view a translation', 
            pass_quiz: 'pass a quiz', 
            explict_vote: 'vote a translation', 
            implicit_vote: 'view additioanl translation',
            create_annotation: 'create an annotation',
            update_annotation: 'update an annotation',
            delete_annotation: 'delete an annotation'}
            
  
  # TODO: decrease score when delete annotation?
  SCORE = {view: 5, pass_quiz: 10, explict_vote: 5, implicit_vote: 2, 
           create_annotation: 10, update_annotation: 0, delete_annotation: 0}
           
  
  PRIVILEGE_MIN_RANK = {view: 1, take_quiz: 2, view_human_annotation: 3,
                        vote_translation: 4, input_translation: 5, 
                        annotate_news_sites: 6, annotate_any_sites: 7}
  
  
  
  @@rules = []


  # TODO: refine rules  
  def self.initialize_rules()
    
    # rank 1 (the default one): view translation
    rule = Rule.new(0, 0, 0, 0, 0)
    @@rules.push(rule)
    
    # rank 2: + take quiz
    rule = Rule.new(SCORE[:view]*5, 5, 0, 0, 0)
    @@rules.push(rule)
    
    # rank 3: + view human annotation
    rule = Rule.new(SCORE[:view]*20 + SCORE[:pass_quiz]*5, 20, 5, 0, 0)
    @@rules.push(rule)
    
    # rank 4:  + vote translation
    rule = Rule.new(SCORE[:view]*50 + SCORE[:pass_quiz]*20, 50, 20, 0, 0)
    @@rules.push(rule)
    
    # rank 5: + input translation
    rule = Rule.new(SCORE[:view]*100 + SCORE[:pass_quiz]*40, 100, 40, 0, 0)
    @@rules.push(rule)
  
    # rank 6: + unblock annotation mode for news sites
    rule = Rule.new(SCORE[:view]*200 + SCORE[:pass_quiz]*60, 200, 60, 0, 0)
    @@rules.push(rule)
    
    # rank 7: +  annotation mode for whatever sites
    rule = Rule.new(SCORE[:view]*300 + SCORE[:pass_quiz]*100, 300, 100, 0, 0)
    @@rules.push(rule)
  end
  
  
  def self.get_score(action_sym)
    if SCORE.key?(action_sym)
      return SCORE[action_sym]
    else
      return 0
    end
  end
  
  
  def self.upgrade_rank(user)
    if @@rules.size==0
      initialize_rules()
    end
    
    if user.rank<@@rules.size and user.score>=@@rules[user.rank+1].score and\
      user.view_count>=@@rules[user.rank+1].view_count and\
      user.quiz_count>=@@rules[user.rank+1].quiz_count and\
      user.vote_count>=@@rules[user.rank+1].vote_count
      return 1
    else
      return 0
    end
  end
  
  # Verify whether the user has enough rank to access certain functions
  # TODO: modify this when rule changes
  def self.validate(rank, privillege_sym)
    if PRIVILEGE_MIN_RANK.key?(privillege_sym)
      return rank>=PRIVILEGE_MIN_RANK[privillege_sym]
    else
      return false
    end
  end
  
  
  
  class Rule
    def initialize(score, view_count, quiz_count, vote_count, annotation_count)
      @score = score
      @view_count = view_count
      @quiz_count = quiz_count
      @vote_count = vote_count
      @annotation_count = annotation_count
    end
    
    attr_reader :score, :view_count, :quiz_count, :vote_count, :annotation_count
    
  end
  
end