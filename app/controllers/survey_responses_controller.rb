class SurveyResponsesController < ApplicationController
  def show
    @survey_response = SurveyResponse
    .includes(
      answers: [
        question_choice: [
          question: :question_choices
        ]
      ]
    )
    .find(params[:id])
    @raw_scores = Hash.new(0)
    @max_scores = Hash.new(0)
    @survey_response.answers.each do |answer|
      @raw_scores[answer.question_choice.creative_quality_id] += answer.question_choice.score
    end
    CreativeQuality.all.each do |cr|
      all_related_question_choices = QuestionChoice.select('max(score) as score').where(creative_quality_id: cr.id).group(:question_id,:creative_quality_id)
      all_related_question_choices.each do |arqc|
        @max_scores[cr.id] += arqc.score
      end
    end
  end

  def index
    @survey_responses = SurveyResponse.all
  end
end
