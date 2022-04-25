temp=$(cat "VERSION")
var1="${temp:8:1}"
var2="${temp:10:1}"
var3="${temp:12:1}"
echo "${{ env.lastCommit }}"
varA="${{ env.lastCommit }}"
 echo "assign to var $varA"
lowerstr=$(echo $varA |tr '[:upper:]' '[:lower:]')
echo "lower = $lowerstr"
if [[ "$lowerstr" == *"#major"* ]]
then
echo "found major in commit"
var1=$((var1+1))
fi
if [[ "$lowerstr" == *"#minor"* ]]
then
echo "found minor in commit"
var2=$((var2+1))
fi
if [[ "$lowerstr" == *"#patch"* ]]
then
echo "found patch in commit"
var3=$((var3+1))
fi
echo "var1 $var1"
echo "var2 $var2"
echo "var3 $var3"
          
cat /dev/null > VERSION
echo -n "Version $var1.$var2.$var3 - \"${{ env.lastCommit }}\"" > VERSION
