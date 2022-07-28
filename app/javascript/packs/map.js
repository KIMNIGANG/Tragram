"use strict";

Object.defineProperty(exports, "__esModule", { value: true });

function initAutocomplete() {
  let name = document.getElementById("loc_name").value;
  let lat = parseFloat(document.getElementById("loc_lat").value);
  let lng = parseFloat(document.getElementById("loc_lng").value);

  if (name == "") {
    name = "Sample marker";
    lat = 36.0927275;
    lng = 140.0967544;
  }

  console.log(lat);

  const place_geo_show = {
    lat: lat,
    name: name,
    lng: lng,
  };

  const map = new google.maps.Map(document.getElementById("map"), {
    center: {
      lat: place_geo_show.lat,
      lng: place_geo_show.lng,
    },
    zoom: 10,
    mapTypeId: "roadmap",
  });

  const input = document.getElementById("pac-input");
  const searchBox = new google.maps.places.SearchBox(input);
  map.controls[google.maps.ControlPosition.TOP_LEFT].push(input);
  // Bias the SearchBox results towards current map's viewport.
  map.addListener("bounds_changed", function () {
    searchBox.setBounds(map.getBounds());
  });
  let markers = [];

  if (place_geo_show.name == "sample marker") {
    markers.push(
      new google.maps.Marker({
        map: map,
        visible: false,
        name: place_geo_show.name,
        position: {
          lat: parseFloat(place_geo_show.lat),
          lng: parseFloat(place_geo_show.lng),
        },
        animation: google.maps.Animation.DROP,
      })
    );
  } else {
    markers.push(
      new google.maps.Marker({
        map: map,
        name: place_geo_show.name,
        position: {
          lat: parseFloat(place_geo_show.lat),
          lng: parseFloat(place_geo_show.lng),
        },
        animation: google.maps.Animation.DROP,
      })
    );
  }

  searchBox.addListener("places_changed", function () {
    var places = searchBox.getPlaces();
    if (places.length == 0) {
      return;
    }
    markers[0].setMap(null);
    // For each place, get the icon, name and location.
    var bounds = new google.maps.LatLngBounds();
    places.forEach(function (place) {
      if (!place.geometry || !place.geometry.location) {
        console.log("Returned place contains no geometry");
        return;
      }
      var icon = {
        size: new google.maps.Size(71, 71),
        origin: new google.maps.Point(0, 0),
        anchor: new google.maps.Point(17, 34),
        scaledSize: new google.maps.Size(25, 25),
      };
      // ピン　立てる
      markers.push(
        new google.maps.Marker({
          map: map,
          icon: icon,
          title: place.name,
          position: place.geometry.location,
          animation: google.maps.Animation.DROP,
        })
      );
      if (place.geometry.viewport) {
        // Only geocodes have viewport.
        bounds.union(place.geometry.viewport);
      } else {
        bounds.extend(place.geometry.location);
      }
      // 場所のlat,lngをもらってくる
      console.log(place.geometry["location"].lat());

      const place_list = document.getElementById("place-list");
      let st = document.createElement("div");
      st.innerHTML = `
        <input type="hidden" name="lat" value="${place.geometry[
          "location"
        ].lat()}">
        <input type="hidden" name="lng" value="${place.geometry[
          "location"
        ].lng()}">
        <input type="hidden" name="name" value="${place.name}">
        `;
      place_list.appendChild(st);
    });
    map.fitBounds(bounds);

    // ここでデータベースの方にplace_geoをアップデートするコードを作成
  });
}
window.initAutocomplete = initAutocomplete;
