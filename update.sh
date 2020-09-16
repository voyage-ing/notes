set -e

git status

echo "Please confirm whether the above information is correct：(y/n)"
read checkflag

if [ $checkflag == "n" ];then
    echo "modify files went wrong"
    exit 1
fi

git add .
echo "modified files adding..."
git status

echo "Please add commit describe"
read describe

git commit -m "$describe"
git push origin master

echo "modified files update successfully"

