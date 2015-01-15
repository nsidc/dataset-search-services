def solr_suggestion_response
  response = {
    'responseHeader' => {
      'status' => 0,
      'QTime' => 1
    },
    'params' => {
        'pf' => 'text_suggest_edge^50'
    },
    'response' => { 'numFound' => 5, 'start' => 0, 'docs' => [
      { 'text_suggest' => 'sea ice' },
      { 'text_suggest' => 'ice core records' },
      { 'text_suggest' => 'sea ice concentration' },
      { 'text_suggest' => 'dome c ice core chemistry and depth and age scale data' },
      { 'text_suggest' => 'sea ice concentrations from nimbus_7 smmr and dmsp ssm/i_ssmis passive microwave data' }
    ] }
  }
  response
end
