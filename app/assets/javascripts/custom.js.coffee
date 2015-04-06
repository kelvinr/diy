$ ->
  userActivity = $('#user-activity')
  hold = $('.hld')

  if $(window).width() < 768
    if userActivity
      userActivity.removeClass 'nav-tabs'
      userActivity.addClass 'nav-pills nav-stacked'
    if hold
      hold.removeClass('align').addClass('hld')
  else if $(window).width() > 768 && hold
    hold.removeClass('hld').addClass('align')

  $(window).resize ->
    if $(this).width() < 768
      userActivity.removeClass 'nav-tabs'
      userActivity.addClass 'nav-pills nav-stacked'
      hold.removeClass('align').addClass('hld')
    else if $(this).width() > 768
      hold.removeClass('hld').addClass('align')
      userActivity.removeClass 'nav-pills nav-stacked'
      userActivity.addClass 'nav-tabs'

  $(document).on('keypress', '#pw input', ->
    $('#confirmation').show()
    $(this).blur(->
      if !$(this).val() and $('h3').text() != 'Registration'
        $('#confirmation').hide()
    )
  )

  categories = $('#search-c')
  questions = $('#search-q')
  cResult = $('.cat-result')
  qResult = $('.que-result')

  $('#all').click( ->
    $(this).siblings('.active').removeClass 'active'
    $(this).addClass 'active'
    $('.divider').show()
    cResult.show()
    qResult.show()
  )
  questions.click( ->
    questions.siblings('.active').removeClass 'active'
    questions.addClass 'active'
    $('.divider').hide()
    cResult.hide()
    qResult.show()
  )
  categories.click( ->
    categories.siblings('.active').removeClass 'active'
    categories.addClass 'active'
    $('.divider').hide()
    qResult.hide()
    cResult.show()
  )

  $('.star').click( (event) ->
    event.preventDefault()
    event.stopPropagation()
    form = $(this)

    $.ajax(
      type: 'POST'
      url: form.attr('action')
      data: form.serialize()
      dataType: "json"
    ).success( ->
      regex = form.attr('action').match(/\/categories\/\d+\//)
      if form.hasClass 'sub'
        form.attr('action', regex + 'unsub')
        form.first('a').html("<a href='#'><i class='glyphicon glyphicon-star'></i> Unsubscribe</a>")
        form.removeClass 'sub'
      else
        form.attr('action', regex + 'sub')
        form.first('a').html("<a href='#'><i class='glyphicon glyphicon-star-empty'></i> Subscribe</a>")
        form.addClass 'sub'
      )
  )

  $('.votes').click( (event) ->
      event.preventDefault()
      event.stopPropagation()
      form = $(this)

      $.ajax(
        type: 'POST'
        url: form.attr('action')
        data: form.serialize()
        dataType: "json"
        ).success( (data) ->
          form.closest('div').find('strong').html('<strong>' + data[0].vote_count + '</strong>')
          if data[0].user_id == data[1].user_id
            alert "You can't vote on your own question or comments"
      )
  )

  $('.container-fluid').on('click', '.answer', (event) ->
      event.preventDefault()
      form = $(this)
      unAnswered = $('.unanswered')

      $.ajax(
        type: 'POST'
        url: form.attr('action')
        data: form.serialize()
      ).success( ->
        $('h5').append(' <i class="answered"></i>')
        form.find(unAnswered).replaceWith('<i class="answered"></i> ')
        unAnswered.hide()
      )
    )

  len = $('.pagination li').length
  activeBtn = $('.active').index()
  i = 3
  while i < len - 4
    i++
    rightBtn = $('.pagination li').eq(activeBtn + i)
    leftBtn = $('.pagination li').eq(activeBtn - i)
    if !rightBtn.hasClass('pager')
      rightBtn.hide()
    if !leftBtn.hasClass('pager')
      leftBtn.hide()
