$defs = Import-Csv $args[0]

$include = '*.java'
$exclude = '*Main.java'

$replacers = @(
  [FieldReplacer]::new(),
  [BuilderReplacer]::new(),
  [GetterReplacer]::new()
)

Get-ChildItem $args[1] -Recurse | ? {

  $_.Name -like $include -and $_.Name -notlike $exclude

} | % {

  $content = Get-Content $_.FullName -Encoding UTF8 -Raw

  foreach ($def in $defs) {
    foreach ($replacer in $replacers) {
      $content = $replacer.Execute($content, $def.before, $def.after)
    }
  }

  $content

}

class FieldReplacer {

  hidden static $regexes = @(
    '(\(){0}(\))',
    '( ){0}((\d)?[ ;\r\n])'
  )

  <#
    '(before)' → '(after)'
    ' before ' → ' after '
    ' before;' → 'after;'
    ' before\n' → ' after\n'
    ' before\r' → ' after\r'
    ' before2 ' → ' after2 '
  #>
  [string] Execute(
    [string]$content,
    [string]$before,
    [string]$after
  ) {
    $result = $content
    foreach ($regex in [FieldReplacer]::regexes) {
      $b = $regex -f $before
      $a = '$1{0}$2' -f $after
      $result = $result -creplace $b, $a
    }
    return $result
  }

}

class BuilderReplacer {

  hidden static [string]$exclude = 'TestDto2'

  [string] Execute(
    [string]$content,
    [string]$before,
    [string]$after
  ) {
    $b = '(?!\s({0})[\s\S]*)(\s[\w]+[\s\r\n]*\.builder\(\)[\s\S]*?\.){1}(\([\s\S]*?\.build\(\);)' -f [BuilderReplacer]::exclude, $before
    $a = '$2{0}$3' -f $after
    return $content -creplace $b, $a
  }

}

class GetterReplacer {

  [string] Execute(
    [string]$content,
    [string]$before,
    [string]$after
  ) {
    $b = $this.ToGetter($before)
    $a = $this.ToGetter($after)
    return $content.Replace($b, $a)
  }

  hidden [string] ToGetter([string]$str) {
    return 'get' + $str.Substring(0, 1).ToUpper() + $str.Substring(1) + '()'
  }

}
