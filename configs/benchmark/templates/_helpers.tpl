{{- define "bookinfoURLs" }}
{{ range $e, $i := until ($.Values.wrk2.app.count | int) }}
{{ range $a, $b := until ($.Values.wrk2.app.namespace | int) }}
        - "http://productpage-{{$i}}.bookinfo-{{$b}}:9080/"
        - "http://productpage-{{$i}}.bookinfo-{{$b}}:9080/"
        - "http://productpage-{{$i}}.bookinfo-{{$b}}:9080/productpage?u=test"
        - "http://productpage-{{$i}}.bookinfo-{{$b}}:9080/"
        - "http://productpage-{{$i}}.bookinfo-{{$b}}:9080/"
        - "http://productpage-{{$i}}.bookinfo-{{$b}}:9080/productpage?u=normal"
        - "http://productpage-{{$i}}.bookinfo-{{$b}}:9080/"
        - "http://productpage-{{$i}}.bookinfo-{{$b}}:9080/"
        - "http://productpage-{{$i}}.bookinfo-{{$b}}:9080/"
        - "http://productpage-{{$i}}.bookinfo-{{$b}}:9080/productpage?u=test"
        - "http://productpage-{{$i}}.bookinfo-{{$b}}:9080/"
        - "http://productpage-{{$i}}.bookinfo-{{$b}}:9080/productpage?u=normal"
        - "http://productpage-{{$i}}.bookinfo-{{$b}}:9080/"
        - "http://productpage-{{$i}}.bookinfo-{{$b}}:9080/"
        - "http://productpage-{{$i}}.bookinfo-{{$b}}:9080/"
        - "http://productpage-{{$i}}.bookinfo-{{$b}}:9080/"
        - "http://productpage-{{$i}}.bookinfo-{{$b}}:9080/productpage?u=test"
        - "http://productpage-{{$i}}.bookinfo-{{$b}}:9080/"
        - "http://productpage-{{$i}}.bookinfo-{{$b}}:9080/productpage?u=normal"
        - "http://productpage-{{$i}}.bookinfo-{{$b}}:9080/"
{{- end -}}
{{ end }}
{{ end }}
