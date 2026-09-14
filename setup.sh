set -e
R=android; rm -rf $R
mkdir -p $R/app/src/main/assets $R/app/src/main/java/com/jjun/hanguksa $R/app/src/main/res/values $R/app/src/main/res/mipmap-anydpi-v26 $R/app/src/main/res/drawable
cp docs/index.html $R/app/src/main/assets/index.html
cat > $R/settings.gradle <<'G'
pluginManagement { repositories { google(); mavenCentral(); gradlePluginPortal() } }
dependencyResolutionManagement { repositoriesMode.set(RepositoriesMode.FAIL_ON_PROJECT_REPOS); repositories { google(); mavenCentral() } }
rootProject.name = "HangukSa"
include ':app'
G
echo "plugins { id 'com.android.application' version '8.5.2' apply false }" > $R/build.gradle
printf 'android.useAndroidX=true\norg.gradle.jvmargs=-Xmx2g\n' > $R/gradle.properties
cat > $R/app/build.gradle <<'G'
plugins { id 'com.android.application' }
android {
  namespace 'com.jjun.hanguksa'
  compileSdk 34
  defaultConfig { applicationId "com.jjun.hanguksa"; minSdk 24; targetSdk 34; versionCode 1; versionName "1.0" }
}
dependencies { implementation 'androidx.appcompat:appcompat:1.7.0'; implementation 'androidx.webkit:webkit:1.11.0' }
G
cat > $R/app/src/main/AndroidManifest.xml <<'G'
<?xml version="1.0" encoding="utf-8"?>
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
  <application android:label="@string/app_name" android:icon="@mipmap/ic_launcher" android:theme="@style/AppTheme" android:allowBackup="true">
    <activity android:name=".MainActivity" android:exported="true" android:configChanges="orientation|screenSize|keyboardHidden" android:windowSoftInputMode="adjustResize">
      <intent-filter><action android:name="android.intent.action.MAIN"/><category android:name="android.intent.category.LAUNCHER"/></intent-filter>
    </activity>
  </application>
</manifest>
G
cat > $R/app/src/main/java/com/jjun/hanguksa/MainActivity.java <<'G'
package com.jjun.hanguksa;
import android.os.Bundle;
import android.webkit.*;
import androidx.appcompat.app.AppCompatActivity;
import androidx.webkit.WebViewAssetLoader;
public class MainActivity extends AppCompatActivity {
  private WebView web;
  @Override protected void onCreate(Bundle b) {
    super.onCreate(b);
    web = new WebView(this); setContentView(web);
    WebSettings s = web.getSettings(); s.setJavaScriptEnabled(true); s.setDomStorageEnabled(true); s.setTextZoom(100);
    final WebViewAssetLoader loader = new WebViewAssetLoader.Builder().addPathHandler("/assets/", new WebViewAssetLoader.AssetsPathHandler(this)).build();
    web.setWebViewClient(new WebViewClient() {
      @Override public WebResourceResponse shouldInterceptRequest(WebView v, WebResourceRequest r) { return loader.shouldInterceptRequest(r.getUrl()); }
    });
    web.loadUrl("https://appassets.androidplatform.net/assets/index.html");
  }
  @Override public void onBackPressed() { if (web.canGoBack()) web.goBack(); else super.onBackPressed(); }
}
G
echo '<resources><string name="app_name">그림으로 보는 한국사</string></resources>' > $R/app/src/main/res/values/strings.xml
cat > $R/app/src/main/res/values/styles.xml <<'G'
<resources><style name="AppTheme" parent="Theme.AppCompat.Light.NoActionBar"><item name="android:statusBarColor">#FBF2D9</item><item name="android:windowLightStatusBar">true</item></style></resources>
G
cat > $R/app/src/main/res/mipmap-anydpi-v26/ic_launcher.xml <<'G'
<?xml version="1.0" encoding="utf-8"?>
<adaptive-icon xmlns:android="http://schemas.android.com/apk/res/android"><background android:drawable="@drawable/ic_bg"/><foreground android:drawable="@drawable/ic_fg"/></adaptive-icon>
G
cat > $R/app/src/main/res/drawable/ic_bg.xml <<'G'
<vector xmlns:android="http://schemas.android.com/apk/res/android" android:width="108dp" android:height="108dp" android:viewportWidth="108" android:viewportHeight="108"><path android:fillColor="#FBF2D9" android:pathData="M0,0h108v108H0z"/></vector>
G
cat > $R/app/src/main/res/drawable/ic_fg.xml <<'G'
<vector xmlns:android="http://schemas.android.com/apk/res/android" android:width="108dp" android:height="108dp" android:viewportWidth="108" android:viewportHeight="108">
  <path android:fillColor="#E0A526" android:pathData="M54,30a24,24 0 1,0 0.01,0z"/>
  <path android:fillColor="#E0A526" android:pathData="M36,38l6,-10l5,8zM72,38l-6,-10l-5,8z"/>
  <path android:fillColor="#22303F" android:pathData="M44,50a3,3 0 1,0 0.01,0zM64,50a3,3 0 1,0 0.01,0zM46,36h3v8h-3zM53,34h3v6h-3zM59,36h3v8h-3z"/>
  <path android:fillColor="#FFFFFF" android:pathData="M48,60a6,4 0 1,0 12,0a6,4 0 1,0 -12,0z"/>
</vector>
G
# PWA 아이콘 생성
python3 - <<'PY'
from PIL import Image, ImageDraw
def icon(n):
    im=Image.new('RGB',(n,n),'#FBF2D9'); d=ImageDraw.Draw(im); s=n/108
    def E(x,y,r,c): d.ellipse([(x-r)*s,(y-r)*s,(x+r)*s,(y+r)*s],fill=c)
    d.polygon([(36*s,38*s),(42*s,28*s),(47*s,36*s)],fill='#E0A526'); d.polygon([(72*s,38*s),(66*s,28*s),(61*s,36*s)],fill='#E0A526')
    E(54,54,24,'#E0A526')
    for x in (46,53,59): d.rectangle([x*s,34*s,(x+3)*s,(42 if x!=53 else 40)*s],fill='#22303F')
    E(44,50,3,'#22303F'); E(64,50,3,'#22303F')
    d.ellipse([48*s,56*s,60*s,64*s],fill='white'); d.arc([50*s,58*s,58*s,64*s],0,180,fill='#22303F',width=max(1,int(1.5*s)))
    return im
for n,f in ((192,'icon-192.png'),(512,'icon-512.png'),(180,'icon-180.png')): icon(n).save('docs/'+f)
PY
echo setup-done
