;; extends

;; replace "-" with a dot
; (list
;    (list_item
;    (list_marker_minus) @conceal (#set! conceal "・")
;  ))

;; empty checkbox
 (list
  (list_item
    (list_marker_minus) @conceal (#set! conceal "")
    (task_list_marker_unchecked)
 ))
 ([
   (task_list_marker_unchecked)
    @text.todo.unchecked
   (#offset! @text.todo.unchecked 0 -2 0 0)
 ] @conceal (#set! conceal "󰄱"))

;; full checkbox
(list
   (list_item
   (list_marker_minus) @conceal (#set! conceal "")
    (task_list_marker_checked)
 ))
 ([
   (task_list_marker_checked)
    @text.todo.checked
   (#offset! @text.todo.checked 0 -2 0 0)
 ] @conceal (#set! conceal ""))

