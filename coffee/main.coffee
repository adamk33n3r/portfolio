titleize = (str) ->
  return str.replace /\w\S*/g, (txt) ->
    return txt.charAt(0).toUpperCase() + txt.substr(1).toLowerCase()

# Adapted from http://www.noamdesign.com/how-to-make-all-anchor-links-scroll-instead-of-jump/
handle_anchors = ->
  # catch all clicks on a tags
  $("a").click ->
    # check if it has a hash (i.e. if it's an anchor link)
    console.log("ouch", this.hash)
    if this.hash
      hash = this.hash.substr(1)
      $toElement = $("[id=#{hash}]")
      toPosition = $toElement.position().top
      # scroll to element
      console.log "sdfkljasdfsdjafkljs", toPosition
      $("#container").animate
        scrollTop: toPosition
        2000
        "easeOutBounce"
    return false
  # do the same with urls with hash too (so on page load it will slide nicely)
  if location.hash
    hash = location.hash
    window.scroll 0, 0
    $("a[href=#{hash}]").click()

animate_scroll_to = (toY) ->
  $("#container").animate
    scrollTop: toY
    2000
    "easeOutBounce"

scrollTo = (section, pushState) ->
  animate_scroll_to section.offsetTop
  if pushState
    history.pushState {section: section.id}, titleize(section.id), section.id

handle_anchors2 = ->
  if location.pathname.length > 1
    section = $("[id=#{location.pathname.substring(1)}]")[0]
    if section
      scrollTo section
      history.pushState {section: section.id}, titleize(section.id), section.id
  else
    history.replaceState({section: "splash-container"}, "splash", "")
  $("a").click ->
    section = this.getAttribute("href")
    $section = $("[id=#{section}]")
    if $section.length > 0
      scrollTo $section[0], true
    return false
  # When they push back
  $(window).on "popstate", ->
    if location.pathname.length > 1
      $section = $("[id=#{location.pathname.substring(1)}]")
      if $section.length > 0
        scrollTo $section[0], false
    else
      animate_scroll_to 0

get_current_section = ->
  current_scroll = $("#container").scrollTop()
  farthest = ""
  $(".row").each ->
    if current_scroll >= this.offsetTop - 100
      farthest = this
#    console.log current_scroll, this.offsetTop, this.id, farthest.id
  return farthest

get_section_after = (section) ->
  return $("##{section}").next ".row"

get_section_before = (section) ->
  return $("##{section}").prev ".row"

goToNextSection = ->
  next_section = get_section_after(history.state.section)[0]
  if next_section
    animate_scroll_to next_section.offsetTop
    history.pushState {section: next_section.id}, titleize(next_section.id), next_section.id

goToPrevSection = ->
  prev_section = get_section_before(history.state.section)[0]
  if prev_section
    animate_scroll_to prev_section.offsetTop
    if prev_section.id == $(".row")[0].id
      history.pushState {section: prev_section.id}, "", "/"
    else
      history.pushState {section: prev_section.id}, titleize(prev_section.id), prev_section.id

check_scrolling = ->
  # Assuming we get them in the order they are on the page
  current_section = get_current_section()
  if history.state.section != current_section.id
    if current_section.id == $(".row")[0].id
      history.pushState {section: current_section.id}, "", "/"
    else
      history.pushState {section: current_section.id}, titleize(current_section.id), current_section.id
#      console.log("You made it to #{farthest.id}!")
SCROLL_DELTA_FACTOR = 1
$ ->
  SCROLL_DELTA_FACTOR = switch $.client.os
    when "Windows", "Linux" then 50
    when "Mac" then 1
  handle_anchors2()
  console.log(titleize("hello friend"))
  $(document.body).keydown (e) ->
    $container = $("#container")
    switch e.which
      when 13
        goToNextSection()
      when 220
        goToPrevSection()
      when 38
        $container.scrollTop($container.scrollTop() - 50)
        check_scrolling()
      when 40
        $container.scrollTop($container.scrollTop() + 50)
        check_scrolling()
      when 72
        animate_scroll_to 0
  $(document.body).mousewheel (e) ->
    $container = $("#container")
    current_scroll = $container.scrollTop()
    $container.scrollTop current_scroll + (SCROLL_DELTA_FACTOR * -e.deltaY)
    check_scrolling()
#    console.log e.deltaX, e.deltaY, e.deltaFactor, $container.scrollTop(), $container.scrollTop() + (50 / -e.deltaY)
