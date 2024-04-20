#!/bin/bash
echo "Content-type: text/html"
echo ""
echo '<html>'
echo '<head>'
echo '<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">'
case $QUERY_STRING in
  "action=disallow&target=tv")
  echo '<title>禁止电视</title>'
  ;;
  "action=allow&target=tv")
  echo '<title>允许电视</title>'
  ;;
  "action=allow10&target=tv")
  echo '<title>电视 10 分钟</title>'
  ;;
  "action=allow15&target=tv")
  echo '<title>电视 15 分钟</title>'
  ;;
  "action=allow20&target=tv")
  echo '<title>电视 20 分钟</title>'
  ;;
  "action=allow25&target=tv")
  echo '<title>电视**30**分钟</title>'
  ;;
  "action=allow30&target=tv")
  echo '<title>电视 30 分钟</title>'
  ;;
  "action=allow60&target=tv")
  echo '<title>电视 1 小时</title>'
  ;;
  *)
  echo '<title>上网控制</title>'
esac
# Save the old internal field separator.
OIFS="$IFS"
# Set the field separator to & and parse the QUERY_STRING at the ampersand.
IFS="${IFS}&"
for args in $QUERY_STRING
  do
  export $args
done
IFS="$OIFS"
result=$(/extra/cgi/netctrl.sh $action $target 2>&1)
echo '</head>'
echo '<body>'
echo '<h1 style=font-size:100px>'
#/extra/cgi/netctrl.sh $action $target
echo $result
echo '</h1>'
echo '</body>'
echo '</html>'
result=$result /extra/cgi/netctrl-mail
 
exit 0
