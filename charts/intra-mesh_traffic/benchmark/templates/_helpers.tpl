{{- define "bookinfoURLs" }}
{{ range $e, $i := until ($.Values.wrk2.app.count | int) }}
{{ range $a, $b := until ($.Values.wrk2.app.namespace | int) }}
        - "http://productpage-{{$i}}.bookinfo-{{$b}}/"
        - "http://productpage-{{$i}}.bookinfo-{{$b}}/"
        - "http://productpage-{{$i}}.bookinfo-{{$b}}/productpage?u=test"
        - "http://productpage-{{$i}}.bookinfo-{{$b}}/"
        - "http://productpage-{{$i}}.bookinfo-{{$b}}/"
        - "http://productpage-{{$i}}.bookinfo-{{$b}}/productpage?u=normal"
        - "http://productpage-{{$i}}.bookinfo-{{$b}}/"
        - "http://productpage-{{$i}}.bookinfo-{{$b}}/"
        - "http://productpage-{{$i}}.bookinfo-{{$b}}/"
        - "http://productpage-{{$i}}.bookinfo-{{$b}}/productpage?u=test"
        - "http://productpage-{{$i}}.bookinfo-{{$b}}/"
        - "http://productpage-{{$i}}.bookinfo-{{$b}}/productpage?u=normal"
        - "http://productpage-{{$i}}.bookinfo-{{$b}}/"
        - "http://productpage-{{$i}}.bookinfo-{{$b}}/"
        - "http://productpage-{{$i}}.bookinfo-{{$b}}/"
        - "http://productpage-{{$i}}.bookinfo-{{$b}}/"
        - "http://productpage-{{$i}}.bookinfo-{{$b}}/productpage?u=test"
        - "http://productpage-{{$i}}.bookinfo-{{$b}}/"
        - "http://productpage-{{$i}}.bookinfo-{{$b}}/productpage?u=normal"
        - "http://productpage-{{$i}}.bookinfo-{{$b}}/"
{{- end -}}
{{ end }}
{{ end }}
