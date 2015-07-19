window.requestAnimationFrame = window.requestAnimationFrame || window.mozRequestAnimationFrame || window.webkitRequestAnimationFrame || window.msRequestAnimationFrame;
###
    get the top offset of given DOM element 

    @param {DOM Element} el
    @return {Number}
###
getOffsetTop = (el) ->
    y = 0
    while el.offsetParent
        y += el.offsetTop
        el = el.offsetParent
    return +y

###
    NScroll
    Better and style-controlable scroll bar for browser window and DOM element

    @param {String} selector
    @param {Object} option
        width
        bgc
        color
        radius
        stepSize
###
window.NScroll = (selector, option) ->
    option = option || {}
    option.width = option.width || 5
    option.bgc = option.bgc || null
    option.color = option.color || '#000000'
    option.radius = option.radius || 5
    option.stepSize = option.stepSize || 18

    el = document.querySelectorAll selector
    el = el[0]
    el.style.position = 'relative'
    el.style.overflow = 'hidden'
    outer = el.clientHeight
    inner = el.scrollHeight


    ###
    Initialize the vitrual scroll, create DOM, bind events handlers
    @param {DOM Element} el
    @api private
    ###
    scrollInit = (el) ->

        ###

            height of scroll bar

        ###
        bar_height = outer * outer / inner

        ###

            create and initialize DOM element and style of container of scroll

        ###
        scr = document.createElement('div')
        console.log scr.style
        scr.style.position = 'absolute'
        scr.style.right = 0
        scr.style.top = 0
        scr.style.height = outer + 'px'
        scr.style.width = option.width + 'px'
        scr.style.backgroundColor = option.bgc

        ###

            DOM element of scroll bar

        ###
        scr_bar = document.createElement('div')
        scr_bar.style.position = 'absolute'
        scr_bar.style.top = 0
        scr_bar.style.right = 0
        console.log bar_height
        scr_bar.style.height = bar_height + 'px'
        scr_bar.style.width = option.width + 'px'
        scr_bar.style.backgroundColor = option.color
        scr_bar.style.borderRadius = option.radius + 'px'

        el.appendChild(scr)
        scr.appendChild(scr_bar)


        ###

            global vars

        ###

        ###

            position when mouse down

        ###
        startY = 0


        ###

            position when mousewheel started

        ###
        startTop = 0


        ###

            ratio of content height to container height

        ###
        ratio = outer / inner

        animation_id = 0


        ###

            move the scroll to the given position, computing and set the content position 
    
            @param {Number} pos

        ###
        scrMove = (pos) ->
            scr.style.top = pos / ratio + 'px'
            scr_bar.style.top = pos + 'px'
            el.scrollTop = pos / ratio


        ###
        
            handle of mousemove event
            move scroll to the position of mouse pointer
        
            @param {Event} e
        
        ###
        mousemoveHandler = (e) ->
            target = e.target
            y = e.clientY 
            dy = y - startY
            curTop = if startTop + dy < 0 then 0 else if startTop + dy > outer - bar_height then outer - bar_height else startTop + dy
            scrMove curTop
            e.preventDefault()


        mouseupHandler = (e) ->
            window.removeEventListener 'mousemove', mousemoveHandler


        mousedownHandler = (e) ->
            target = e.target
            startY = e.clientY
            startTop = scr_bar.offsetTop
            if target is scr_bar
                window.addEventListener 'mousemove', mousemoveHandler, false
                e.preventDefault()
                return false
            scr_bar.style.top = (if e.clientY > outer - bar_height then outer - bar_height else e.clientY) + 'px'
            e.preventDefault()


        ###

            @param {DOM} el
            @param {Number} direction: 1 -> up
                                       -1 -> down

            @return {Bool}

        ###
        isOverflow = (el, direction) ->
            scroll_top = el.scrollTop;
            if direction is 1
                return (if scroll_top > 0 then true else false)

            bottom = inner - scroll_top - outer
            return (if bottom > 0 then true else false)


        ###

            Animate function

            @param {DOM} el
            @param {Number} dy

        ###
        setScrAnimate = (el, dy) ->
            finished = 0
            y_step = dy / 20
            acc = y_step / 40
            step = () ->
                if isOverflow(el, -dy/Math.abs(dy))
                    top = el.scrollTop * ratio
                    finished += y_step
                    scrMove top + y_step
                    if y_step / acc > 1 
                        y_step -= acc
                        animation_id = requestAnimationFrame(step) if finished / dy < 1 and isOverflow el, dy/Math.abs dy 
                return false
            animation_id = requestAnimationFrame(step) if isOverflow(el, -dy/Math.abs dy )


        ###

            @param {Event} e

        ###
        wheelHandler = (e) ->
            target = e.target
            deltaY = -e.wheelDeltaY || 0
            deltaY || (deltaY = -e.wheelDelta || 0)
            Math.abs(deltaY) > 1.2 && (deltaY *= option.stepSize / 120)
            e.preventDefault()
            setScrAnimate(el, deltaY)


        scr.addEventListener 'mousedown', mousedownHandler
        window.addEventListener 'mouseup', mouseupHandler
        el.addEventListener 'mousewheel', wheelHandler

    scrollInit(el)
