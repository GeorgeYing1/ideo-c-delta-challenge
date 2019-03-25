class CreativeQualitiesController < ApplicationController
  include ApplicationHelper
  def index
    @creative_qualities = CreativeQuality.all

    @raw_scores = Hash.new(0)
    @max_scores = Hash.new(0)
    @normalized_scores = Hash.new(0)

    Answer.find_each do |ans|
      @raw_scores[ans.question_choice.creative_quality_id] += ans.question_choice.score
    end

    CreativeQuality.find_each do |cr|
      all_related_question_choices = QuestionChoice.select('max(score) as score').where(creative_quality_id: cr.id).group(:question_id,:creative_quality_id)
      all_related_question_choices.each do |arqc|
        @max_scores[cr.id] += arqc.score
      end
    end

    len = SurveyResponse.all.length
    @max_scores = @max_scores.map { |k, v| [k, v * len] }.to_h

    CreativeQuality.find_each do |cr|
      @normalized_scores[cr.id] = (@raw_scores[cr.id].to_f / @max_scores[cr.id] * 100).round
      if @normalized_scores[cr.id] > 100
        @normalized_scores[cr.id] = 100
      elsif @normalized_scores[cr.id] < (-100)
        @normalized_scores[cr.id] = -100
      end
    end

    respond_to do |format|
      format.html
      format.json { render json: mock_creative_quality_scores }
    end
  end
end
