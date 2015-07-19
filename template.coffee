class templ
    constructor: () ->
        @models = {}

    bind: (value, model) ->
        view_elems = document.querySelectorAll '[data-model="' + model + '"]'
        result="var p=[];p.push('"+html.replace(/[\r\n\t]/g," ").replace(/\@\{\#(.*?)\}/g,"');p.push($1);p.push('").replace(/@\{/g,"');").replace(/\}/g,"p.push('")+"');return p.join('');"
        n

