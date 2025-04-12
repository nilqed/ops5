(ql:quickload :ops5)
(in-package :ops)

(ops-init)

(wm)
(ppwm)

(make Hello)
(make Hello there)
(make Volume 123 345 5667)
(make Bye)
(wm)

(format t "~%~%Removing facts 1 and 2~%~%")

(remove 1 2)
(wm)


(p rule1 (start) --> (make restart))
(pm)
(cs)
(watch)
(make start)
(cs)
(pm)
(run)
(wm)

(reset-ops)
(run)

(ops-init)
(literalize point px py pz)
(p rule2 (point <x> <y> <z>) --> (write crlf <z> <y> "ok" crlf))
(make point ^px 12 ^py 45 ^pz 0)





