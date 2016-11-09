class AnnotationHistory < ActiveRecord::Base
  attr_accessible :annotation_id, :client_ann_id, :lang, :user_id
  belongs_to :annotation
end
